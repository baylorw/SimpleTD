extends Node2D

signal creep_reached_base

const good_color := Color(0,1,0, 0.5)
const bad_color  := Color(1,0,0, 0.5)

@export var money := 200

@onready var ui: LevelUI = %UI
@onready var map_view_settings_panel: PopupPanel = %MapViewSettingsPanel


#--- Pointers to run-time loaded map.
var terrain_tilemap : TileMapLayer 
var blocker_tilemap : TileMapLayer 
var group_1_start_marker 
var group_2_start_marker 
var group_1_end_marker 
var group_2_end_marker 
var path_line_1: PathLine 
var path_line_2: PathLine 
var path_follower_prototype: PathFollower 
var kill_zone: Area2D 

var group_1_start_coord_global : Vector2
var group_1_start_coord_map : Vector2i
var group_1_path_global : Array[Vector2] = []
var group_2_start_coord_global : Vector2
var group_2_start_coord_map : Vector2i
var group_2_path_global : Array[Vector2] = []
var group_1_end_coord_global : Vector2
var group_1_end_coord_map : Vector2i
var group_2_end_coord_global : Vector2
var group_2_end_coord_map : Vector2i

var astar_grid = AStarGrid2D.new()
var is_attempting_tower_placement = false
#--- The tower being dragged by the mouse when building a new tower.
var new_tower : Tower
var should_show_path := true
var tower_by_map_coord : Dictionary = {}

# TODO: Move this to a Wave object
var spawn_delay_in_wave_ms : float = 300


func _ready():
	Engine.time_scale = 1
	Music.play_song("apple")
	
	map_view_settings_panel.hide()
	
	load_level()
	
	CurrentLevel.money_starting = money
	CurrentLevel.reset()
	ui.show_health()
	ui.show_money()
	ui.show_wave()
	
	creep_reached_base.connect(on_creep_reached_base)
	
	build_astar_grid()
	
	setup_path_coords()
	calculate_default_paths()
	show_default_paths()
	
	setup_build_buttons()

func load_level():
	if "" == Globals.level_name:
		Globals.level_name = "res://levels/default/default_level.tscn"
	var packed_scene = load(Globals.level_name)
	if (null == packed_scene):
		print("Globals.level_name was blank or an invalid file")
		assert(packed_scene)
	var play_area = packed_scene.instantiate()
	#--- Adding to a specific node to put it in the middle of the tree rather than at the end
	#---	where it would block the Win message.
	%LevelData.add_child(play_area)
	
	#--- Normally we'd want these variables set by @onready but we load them late
	#---	so we have to set the variables here.
	#--- Set variables to point to the loaded map data.
	#terrain_tilemap = %GroundTileMapLayer
	terrain_tilemap = %LevelData/Map/GroundTileMapLayer
	blocker_tilemap = %LevelData/Map/WallsTileMapLayer
	group_1_start_marker = %LevelData/Map/Paths/StartGroup1
	group_2_start_marker = %LevelData/Map/Paths/StartGroup2
	group_1_end_marker = %LevelData/Map/Paths/EndGroup1
	group_2_end_marker = %LevelData/Map/Paths/EndGroup2
	path_line_1 = %LevelData/Map/Paths/PathLine1
	path_line_2 = %LevelData/Map/Paths/PathLine2
	path_follower_prototype = %LevelData/Map/PathFollowerPrototype
	kill_zone = %LevelData/Map/Paths/KillZone
	
	kill_zone.body_entered.connect(_on_kill_zone_body_entered)
	

func setup_build_buttons():
	for i in get_tree().get_nodes_in_group("build_tower_buttons"):
		var tower_name = i.get_meta("tower_name")
		i.pressed.connect(Callable(on_build_tower_button_pressed).bind(tower_name))
		i.mouse_entered.connect(Callable(on_build_tower_button_mouse_entered).bind(tower_name))

func setup_path_coords():
	group_1_start_coord_global = group_1_start_marker.position
	group_2_start_coord_global = group_2_start_marker.position
	group_1_start_coord_map = coordinate_global_to_map(group_1_start_coord_global)
	group_2_start_coord_map = coordinate_global_to_map(group_2_start_coord_global)
	group_1_end_coord_global = group_1_end_marker.position
	group_2_end_coord_global = group_2_end_marker.position
	group_1_end_coord_map = coordinate_global_to_map(group_1_end_marker.position)
	group_2_end_coord_map = coordinate_global_to_map(group_2_end_marker.position)

func on_build_tower_button_mouse_entered(tower_name: String):
	if !Towers.towers.keys().has(tower_name):
		ui.show_details("missing info in Towers global")
		return
	var tower : Tower = Towers.towers[tower_name]
	ui.show_details(tower.get_description())

func on_build_tower_button_pressed(tower_name : String):
	#--- If they are already trying to build something, cancel that one.
	if is_attempting_tower_placement:
		cancel_build()
	
	if CurrentLevel.LevelStatus.BUILD != CurrentLevel.level_status:
		print("Can't build new towers, game currently in status=" + str(CurrentLevel.level_status))
		return
	is_attempting_tower_placement = true
	var tower_scene_fqn = "res://scenes/towers/%s.tscn" % tower_name
	#print("build button pressed for %s" % tower_scene_fqn)
	var tower_data = load(tower_scene_fqn)
	new_tower = tower_data.instantiate()
	#--- You MUST add this to the scene graph before modifying properties that use the onready variables.
	%Towers.add_child(new_tower)
	new_tower.set_range_color(bad_color)
	new_tower.show_range(true)

func _physics_process(_delta: float) -> void:
	if !is_attempting_tower_placement:
		return
	
	if can_build():
		new_tower.set_range_color(good_color)
		new_tower.set_tower_color(Color.WHITE)
	else:
		new_tower.set_range_color(bad_color)
		new_tower.set_tower_color(bad_color)
	new_tower.position = get_global_mouse_position()

func build_astar_grid():
	astar_grid.cell_size = terrain_tilemap.tile_set.tile_size
	astar_grid.region = terrain_tilemap.get_used_rect()
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	#astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_AT_LEAST_ONE_WALKABLE
	astar_grid.default_compute_heuristic  = AStarGrid2D.HEURISTIC_EUCLIDEAN
	astar_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_EUCLIDEAN
	astar_grid.update()
	
	#--- Remove spots where there is no nav layer.
	# ASSUMPTION: User doesn't want to assume all terrain is navigable and specifies that using
	#			  the built-in nav layer.
	var terrain_positions : Array[Vector2i] = terrain_tilemap.get_used_cells()
	for terrain_position in terrain_positions:
		var tile_data = terrain_tilemap.get_cell_tile_data(terrain_position)
		var nav_shape : NavigationPolygon = tile_data.get_navigation_polygon(0)
		if null != nav_shape:
			var oc = nav_shape.get_outline_count()
			if oc == 0:
				astar_grid.set_point_solid(terrain_position)

	#--- Remove spots where they can't walk because something is already there.
	var blocker_positions : Array[Vector2i] = blocker_tilemap.get_used_cells()
	for blocker_position in blocker_positions:
		astar_grid.set_point_solid(blocker_position)

func _unhandled_input(event: InputEvent):
	if is_attempting_tower_placement:
		if event.is_action_pressed("left_click"):
			if can_build():
				build_tower()
			else:
				print("You can't build there")
				cancel_build()
		elif event.is_action_pressed("ui_cancel") or event.is_action_pressed("right_click"):
			cancel_build()
		#else:
			#print("input=" + str(event))
			
	elif event.is_action_pressed("left_click"):
		var tile_position = coordinate_global_to_map(get_global_mouse_position())
		if null == tile_position:
			return
		if tower_by_map_coord.has(tile_position):
			var tower = tower_by_map_coord[tile_position]
			tower.toggle_show_range()
			ui.show_details(tower.get_description())
	#elif !is_attempting_tower_placement and event.is_action_pressed("left_click"):
		#new_tower.fire_at_mouse()
		
	elif event.is_action_pressed("ui_cancel"):
		_on_quit_button_pressed()

func build_tower():
	is_attempting_tower_placement = false

	CurrentLevel.money -= new_tower.cost
	ui.show_money()

	var map_coord = coordinate_global_to_map(new_tower.position)
	new_tower.position = coordinate_map_to_global(map_coord)
	tower_by_map_coord[map_coord] = new_tower

	new_tower.show_range(false)

func cancel_build():
	is_attempting_tower_placement =false
	new_tower.queue_free()

func can_build():
	if CurrentLevel.level_status != CurrentLevel.LevelStatus.BUILD:
		print("can't build, level isn't in build mode")
		return false
	if !is_attempting_tower_placement:
		print("can't build, !is_attempting_tower_placement")
		return false
	if new_tower.cost > CurrentLevel.money:
		#print("can't build, tower is too expensive")
		return false
	if !is_a_buildable_position_global(get_global_mouse_position()):
		return false
	return true

func print_mouse_location():
	var mouse_place_g = get_global_mouse_position()
	var l = to_local(mouse_place_g)
	var mt = terrain_tilemap.local_to_map(l)
	var mb = blocker_tilemap.local_to_map(l)
	print("g="+str(mouse_place_g)+" l="+str(l)+" mt="+str(mt)+" mb="+str(mb))
	
#func repath_creeps():
	#calculate_default_paths()
	#show_default_paths()
#
	#var creeps = get_tree().get_nodes_in_group("creeps")
	#for creep in creeps:
		#var creep_position_map = coordinate_global_to_map(creep.position)
		#var path_in_map_coords = astar_grid.get_id_path(creep_position_map, goal_coord_map)
		#var path = coords_map_to_global(path_in_map_coords)
		#creep.follow(path)

func calculate_default_paths():
	#print("calculate_default_paths")

	var path_1_in_map_coords = astar_grid.get_id_path(group_1_start_coord_map, group_1_end_coord_map)
	group_1_path_global = coords_map_to_global(path_1_in_map_coords)
	#print("path map from=" + str(group_1_start_coord_map) + " to=" + str(group_1_end_coord_map) + " path=" + str(path_1_in_map_coords))
	#print("path local=" + str(coords_map_to_local(path_1_in_map_coords)))
	
	var path_2_in_map_coords = astar_grid.get_id_path(group_2_start_coord_map, group_2_end_coord_map)
	group_2_path_global = coords_map_to_global(path_2_in_map_coords)

func show_default_paths():
	path_line_1.points = PackedVector2Array(group_1_path_global)
	path_line_2.points = PackedVector2Array(group_2_path_global)
	#print("show_default_paths, path1.size=" + str(path_line_1.points.size()) + " path2.size=" + str(path_line_2.points.size()))

func spawn_creeps():
	#print("spawn_creeps()")
	CurrentLevel.wave_number += 1
	ui.show_wave()
	CurrentLevel.level_status = CurrentLevel.LevelStatus.WAVE
	if group_1_path_global.is_empty() or group_2_path_global.is_empty():
		print("no paths so calculating them")
		calculate_default_paths()
		show_default_paths()

	#print("spawn time")
	for i in 5:
		spawn_creep_at(group_1_start_coord_global, group_1_path_global)
		spawn_creep_at(group_2_start_coord_global, group_2_path_global)
		await get_tree().create_timer(spawn_delay_in_wave_ms / 1000).timeout
		print("Creep spawned. count=" + str(%Creeps.get_child_count()))

func spawn_creep_at(start_position_global : Vector2, path : Array[Vector2]):
	#print("spawn_creep_at() global=" + str(start_position_global))
	# TODO: Need more than one creep type
	var new_enemy : PathFollower = path_follower_prototype.duplicate()
	new_enemy.add_to_group("creeps")
	new_enemy.position = start_position_global
	%Creeps.add_child(new_enemy, true)
	new_enemy.destroyed.connect(on_creep_destroyed)
	new_enemy.tree_exited.connect(on_creep_freed)

	if path.is_empty():
		print("!!! NO PATH FOUND !!! from=" + str(start_position_global))
		new_enemy.queue_free()
		return

	#--- Path following is destructive so give each agent their own copy of the path.
	new_enemy.follow(path.duplicate())

func coords_map_to_global(coords_map : Array[Vector2i]) -> Array[Vector2]:
	var coords_global : Array[Vector2] = []
	for coord_map in coords_map:
		var coord_global = coordinate_map_to_global(coord_map)
		coords_global.push_back(coord_global)
	return coords_global

func coordinate_global_to_map(coordinate_global : Vector2i) -> Vector2i:
	var coordinate_local = to_local(coordinate_global)
	var coordinate_map   = terrain_tilemap.local_to_map(coordinate_local)
	return coordinate_map

func coordinate_global_to_map_to_global(coordinate_global : Vector2i) -> Vector2:
	var coordinate_local = to_local(coordinate_global)
	var coordinate_map   = terrain_tilemap.local_to_map(coordinate_local)
	var global_but_tile_centered = coordinate_map_to_global(coordinate_map)
	return global_but_tile_centered

func coordinate_map_to_global(coordinate_map : Vector2i) -> Vector2:
	var coordinate_local  = terrain_tilemap.map_to_local(coordinate_map)
	var coordinate_global = to_global(coordinate_local)
	return coordinate_global


## Needed: 
## 1. It's a wall, not a walkable
## 2. The wall doesn't already have a tower on it
func is_navigable(tile_position : Vector2i) -> bool:
	var tile_data = terrain_tilemap.get_cell_tile_data(tile_position)
	if (null == tile_data):
		return false
	var nav_shape = tile_data.get_navigation_polygon(0)
	if null == nav_shape:
		return false
	if 0 == nav_shape.get_outline_count():
		return false
	return true

## Could be a wall (which we can build on), could be trees or a pit or something (which we can't).
func is_blocked(tile_position : Vector2i) -> bool:
	var source_id = blocker_tilemap.get_cell_source_id(tile_position)
	var is_blocked = (-1 != source_id)
	return is_blocked

func is_occupied(tile_position : Vector2i) -> bool:
	return tower_by_map_coord.keys().has(tile_position)

func is_a_buildable_position(tile_position : Vector2i) -> bool:
	#if is_navigable(tile_position):
		#print("that spot is navigable, towers don't go there")
		#return false
	# TODO: Explicitly mark buildable positions (to differentiate from non-nav and also not-buildable)
	if !is_blocked(tile_position):
		return false
	if is_occupied(tile_position):
		return false
	return true

func is_a_buildable_position_global(position_global : Vector2) -> bool:
	var position_local = to_local(position_global)
	var position_tilemap = terrain_tilemap.local_to_map(position_local)
	return is_a_buildable_position(position_tilemap)


#####################
##     GAME EVENTS
#####################
func on_creep_destroyed():
	ui.show_money()
	#print("Creep destroyed. count=" + str(%Creeps.get_child_count()))
	#if 0 == %Creeps.get_child_count():
		#print("wave over, back to build mode")
		#CurrentLevel.level_status = CurrentLevel.LevelStatus.BUILD

## The creep has left the scene graph, probably after a queue_free().
## Because it was queued, we can't get an accurate count of creeps remaining
##	in the other methods (on_destroyed, etc.).
func on_creep_freed():
	print("tree_exited, remaining creeps=" + str(%Creeps.get_child_count()))
	#ui.log("creeps=" + str(%Creeps.get_child_count()))
	ui.show_details("creeps=" + str(%Creeps.get_child_count()))

	#--- If we've already lost it doesn't matter what the creeps are doing now.
	if CurrentLevel.level_status == CurrentLevel.LevelStatus.LOST:
		return
		
	if (0 == %Creeps.get_child_count()) and (CurrentLevel.level_status == CurrentLevel.LevelStatus.WAVE):
		if CurrentLevel.wave_number == CurrentLevel.wave_number_max:
			CurrentLevel.level_status = CurrentLevel.LevelStatus.WON
			on_win()
		else:
			print("wave over, we survived, back to build mode")
			ui.log("wave done")
			CurrentLevel.level_status = CurrentLevel.LevelStatus.BUILD
		

func on_creep_reached_base():
	print("on_creep_reached_base")
	CurrentLevel.base_health -= 1
	ui.show_health()
	if 0 == CurrentLevel.base_health:
		CurrentLevel.level_status = CurrentLevel.LevelStatus.LOST
		on_lose()

func _on_kill_zone_body_entered(body: Node2D):
	print("kill zone entered by " + str(body))
	if !(body is PathFollower):
		return
	creep_reached_base.emit()
	body.queue_free()

func on_win():
	print("GAME OVER, you win!")
	%WinScoreLabel.text = "Score: %s/%s" % [CurrentLevel.base_health, CurrentLevel.base_health_max]
	Music.play_song("fruit")
	center_control(%WinnerMessage)

func on_lose():
	print("GAME OVER, you lose")
	Music.play_song("loser")
	center_control(%LoserMessage)
	

func center_control(control : Container):
	control.position = Vector2(
		get_viewport().size.x / 2 - control.get_rect().size.x / 2,
		get_viewport().size.y / 2 - control.get_rect().size.y / 2
	)

func _on_quit_button_pressed():
	get_tree().change_scene_to_file("res://menus/level_selection/level_selection.tscn")

func _on_restart_button_pressed():
	get_tree().reload_current_scene()

func _on_send_wave_button_pressed():
	if CurrentLevel.level_status != CurrentLevel.LevelStatus.BUILD:
		return
	spawn_creeps()

func _on_pause_button_pressed() -> void:
	get_tree().paused = !get_tree().is_paused()
	
func _on_speed_half_button_pressed() -> void:
	Engine.time_scale = 0.5
func _on_speed_normal_button_pressed() -> void:
	Engine.time_scale = 1
func _on_speed_2_button_pressed() -> void:
	Engine.time_scale = 2
func _on_speed_5_button_pressed() -> void:
	Engine.time_scale = 5


func _on_r_pressed() -> void:
	ui.show_health()
	ui.show_money()
	ui.show_wave()
	print("creep count=" + str(%Creeps.get_child_count()))
	map_view_settings_panel.popup_centered()

class_name LevelManager extends Node2D

signal creep_reached_base
#signal wave_ended

const good_color := Color(0,1,0, 0.5)
const bad_color  := Color(1,0,0, 0.5)
const message_time_s : float = 0.75

#var money : int

@onready var ui: LevelUI = %UI
@onready var map_view_settings_panel: PopupPanel = %MapViewSettingsPanel
@onready var wave_start_message: VBoxContainer = %WaveStartMessage
@onready var wave_end_message: VBoxContainer = %WaveEndMessage
@onready var wave_start_label: Label = %WaveStartLabel
@onready var wave_end_label: Label = %WaveEndLabel
@onready var tower_info_popup_panel: PopupPanel = %TowerInfoPopupPanel

@onready var shade_tile_map: TileMapLayer = %ShadeTileMap
@onready var tile_borders_tile_map: TileMapLayer = %TileBordersTileMap
@onready var path_tile_map: TileMapLayer = %PathTileMap
@onready var annotations_tile_map: TileMapLayer = %AnnotationsTileMap

var play_area : LevelData
var path_by_name := {}


#--- Pointers to run-time loaded map.
var terrain_tilemap : TileMapLayer 
var blocker_tilemap : TileMapLayer 
var path_follower_prototype: Creep 

var astar_grid = AStarGrid2D.new()
var is_attempting_tower_placement = false
#--- The tower being dragged by the mouse when building a new tower.
var new_tower : Tower
var should_show_path := true
var tower_by_map_coord : Dictionary = {}

var current_wave : Wave
var max_wave_ticks : int

var selected_tower : Tower

func _ready():
	Engine.time_scale = 1
	Music.play_song("apple")
	
	map_view_settings_panel.hide()
	wave_start_message.visible = false
	wave_end_message.visible = false
	tower_info_popup_panel.hide()
	
	load_level()
	build_astar_grid()
	calculate_default_paths()
	show_default_paths()
	
	CurrentLevel.money_starting = CurrentLevel.money
	CurrentLevel.reset()
	ui.show_health()
	ui.show_money()
	ui.show_wave()
	show_wave_contents(1)
	
	creep_reached_base.connect(on_creep_reached_base)
	
	setup_build_buttons()

func load_level():
	if "" == Globals.level_name:
		Globals.level_name = "res://levels/default/default_level.tscn"
	var packed_scene = load(Globals.level_name)
	if (null == packed_scene):
		print("Globals.level_name was blank or an invalid file")
		assert(packed_scene)
	play_area = packed_scene.instantiate() as LevelData
	
	#print("play_area.starting_money=" + str(play_area.starting_money))
	#self.money = play_area.starting_money
	CurrentLevel.money = play_area.starting_money
	#print("my money=" + str(money))
	
	#--- Adding to a specific node to put it in the middle of the tree rather than at the end
	#---	where it would block the Win message.
	%LevelData.add_child(play_area)
	
	#--- Normally we'd want these variables set by @onready but we load them late
	#---	so we have to set the variables here.
	terrain_tilemap = %LevelData/Map/GroundTileMapLayer
	blocker_tilemap = %LevelData/Map/WallsTileMapLayer
	
	#--- Sometimes we draw stuff over both the tilemap AND the path.
	#--- We have a special place in the scenetree for that.
	var decorations_tilemap = %LevelData/Map/DecorationsTileMapLayer
	if decorations_tilemap:
		decorations_tilemap.get_parent().remove_child(decorations_tilemap)
		%Decorations.add_child(decorations_tilemap)
	
	path_by_name = play_area.path_by_name
	var path_line_resource = load("res://scenes/path_line/path_line.tscn")
	for path in path_by_name.values():
		path.kill_zone.body_entered.connect(_on_kill_zone_body_entered)
		#--- Calculate some data.
		path.start_coord_global = coordinate_map_to_global(path.start_coord_map)
		path.end_coord_global   = coordinate_map_to_global(path.end_coord_map)
		#--- Create the visual representation of the paths.
		var path_view = path_line_resource.instantiate()
		path_view.name = path.name + "_view"
		path.display = path_view
		%Paths.add_child(path_view)
	
	CurrentLevel.wave_number_max = play_area.waves.size()
	
func setup_build_buttons():
	for i in get_tree().get_nodes_in_group("build_tower_buttons"):
		var tower_name = i.get_meta("tower_name")
		i.pressed.connect(Callable(on_build_tower_button_pressed).bind(tower_name))
		i.mouse_entered.connect(Callable(on_build_tower_button_mouse_entered).bind(tower_name))

func on_build_tower_button_mouse_entered(tower_name: String):
	if !Towers.towers.keys().has(tower_name):
		ui.show_details("missing info in Towers global. tower_name=" + tower_name)
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
	var tower_scene_fqn = "res://scenes/towers/%s.tscn" % tower_name
	#print("build button pressed for %s" % tower_scene_fqn)
	var tower_data = load(tower_scene_fqn)
	if !tower_data:
		print("ERROR: Unknown tower. FQN=" + tower_scene_fqn)
		return
	new_tower = tower_data.instantiate()
	is_attempting_tower_placement = true
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
		if CurrentLevel.level_status != CurrentLevel.LevelStatus.BUILD:
			return
		var tile_position = coordinate_global_to_map(get_global_mouse_position())
		if null == tile_position:
			return
		if tower_by_map_coord.has(tile_position):
			selected_tower = tower_by_map_coord[tile_position]
			selected_tower.toggle_show_range()
			ui.show_details(selected_tower.get_description())
			show_tower_info(get_global_mouse_position())
	elif event.is_action_pressed("right_click"):
		if CurrentLevel.level_status != CurrentLevel.LevelStatus.BUILD:
			return
		var tile_position = coordinate_global_to_map(get_global_mouse_position())
		if null == tile_position:
			return
		if tower_by_map_coord.has(tile_position):
			selected_tower = tower_by_map_coord[tile_position]
			selected_tower.toggle_show_range()
			ui.show_details(selected_tower.get_description())
			show_tower_info(get_global_mouse_position())
	#elif !is_attempting_tower_placement and event.is_action_pressed("left_click"):
		#new_tower.fire_at_mouse()
		
	elif event.is_action_pressed("ui_cancel"):
		_on_quit_button_pressed()

func show_tower_info(new_position: Vector2):
	if tower_info_popup_panel.visible:
		print("it's already showing so we're hiding it.")
		tower_info_popup_panel.hide()
		tower_info_popup_panel.visible = false
	print("popup.visible=" + str(tower_info_popup_panel.visible))
	tower_info_popup_panel.position = new_position + Vector2(50, 0)
	tower_info_popup_panel.set_info(selected_tower)
	#print("popping up")
	#tower_info_popup_panel.popup_centered()
	print("popping up again, damn it")
	tower_info_popup_panel.popup()
	
func build_tower():
	is_attempting_tower_placement = false

	CurrentLevel.money -= new_tower.cost
	ui.show_money()

	var map_coord = coordinate_global_to_map(new_tower.position)
	new_tower.position = coordinate_map_to_global(map_coord)
	new_tower.position_tile = map_coord
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

func calculate_default_paths():
	for path in path_by_name.values():
		path.waypoints_map = astar_grid.get_id_path(path.start_coord_map, path.end_coord_map)
		path.waypoints_global = coords_map_to_global(path.waypoints_map)

func show_default_paths():
	for path in path_by_name.values():
		path.display.points = PackedVector2Array(path.waypoints_global)

func show_wave_contents(wave_number: int):
	var first_creep : Creep = get_first_creep_in_wave(wave_number)
	var sprite : AnimatedSprite2D = first_creep.get_sprite()
	var animation_name = sprite.animation
	%CurrentWaveIcon.texture = sprite.sprite_frames.get_frame_texture(animation_name, 0)
	%CurrentWaveIcon.modulate = sprite.modulate
	%CurrentWaveDetails.text = "%s lvl %s\n%shp $%s" % [first_creep.name, first_creep.level, first_creep.health, first_creep.kill_value]
	
	if wave_number >= CurrentLevel.wave_number_max:
		%NextWaveIcon.texture = null
		%NextWaveDetails.text = ""
	else:
		first_creep = get_first_creep_in_wave(wave_number+1)
		sprite = first_creep.get_sprite()
		animation_name = sprite.animation
		%NextWaveIcon.texture = sprite.sprite_frames.get_frame_texture(animation_name, 0)
		%NextWaveIcon.modulate = sprite.modulate
		%NextWaveDetails.text = "%s lvl %s\n%shp $%s" % [first_creep.name, first_creep.level, first_creep.health, first_creep.kill_value]

func get_first_creep_in_wave(wave_number: int) -> Creep:
	var wave : Wave = play_area.waves[wave_number-1]
	var first_creep : Creep
	for path_wave in wave.wave_by_path.values():
		var specifier : CreepSpecifier = path_wave.creeps[0]
		var creep_resource = CreepBook.creep_by_name[specifier.name]
		#var new_enemy : Creep = creep_resource.instantiate()
		first_creep = creep_resource.instantiate()
		first_creep.set_level(specifier.level)
	return first_creep

func spawn_creeps():
	CurrentLevel.wave_number += 1
	CurrentLevel.wave_tick = 0
	CurrentLevel.level_status = CurrentLevel.LevelStatus.WAVE
	ui.show_wave()
	#show_wave_contents(CurrentLevel.wave_number)
	
	current_wave = play_area.waves[CurrentLevel.wave_number-1]
	max_wave_ticks = current_wave.max_wave_ticks()
	%WaveTickTimer.wait_time = current_wave.time_between_creeps_sec
	
	wave_start_label.text = "Wave %s" % [CurrentLevel.wave_number]
	wave_start_message.visible = true
	var tween = fade(wave_start_message, 0, 1, 0.5)
	await tween.finished
	await get_tree().create_timer(message_time_s).timeout
	tween = fade(wave_start_message, 1, 0, 0.5)
	await tween.finished
	wave_start_message.visible = false
	
	%WaveTickTimer.start()

func fade(object, start: float, end: float, time_length_s: float, should_loop: bool=false) -> Tween:
	var tween = create_tween()
	if should_loop:
		tween.set_loops()
	tween.tween_property(object, "modulate:a", end, time_length_s).from(start)
	if should_loop:
		tween.tween_property(object, "modulate:a", start, time_length_s).from(end)
	return tween

func _on_wave_tick_timer_timeout() -> void:
	CurrentLevel.wave_tick += 1
	#--- If there are no more creeps to spawn, turn off the timer.
	if CurrentLevel.wave_tick > max_wave_ticks:
		%WaveTickTimer.stop()
	
	for path_name in current_wave.wave_by_path.keys():
		var path_wave = current_wave.wave_by_path[path_name]
		if CurrentLevel.wave_tick > path_wave.creeps.size():
			continue
		var creep_specifier = path_wave.creeps[CurrentLevel.wave_tick-1]
		var creep_name = creep_specifier.name
		if "no-op" == creep_name:    # These are time spacers, not real creeps
			continue
		var creep_resource = CreepBook.creep_by_name[creep_name]
		if !creep_resource:
			continue
		var path : Path = path_by_name[path_name]
		var creep_instance_name = "creep_%s_%s" % [path_name, CurrentLevel.wave_tick]
		spawn_creep_at(path.start_coord_global, path.waypoints_global, creep_instance_name, creep_resource, creep_specifier.level)

func spawn_creep_at(start_position_global : Vector2, path : Array[Vector2], creep_name: String, creep_resource, level: int):
	var new_enemy : Creep = creep_resource.instantiate()
	new_enemy.set_level(level)
	new_enemy.name = creep_name
	new_enemy.add_to_group("creeps")
	new_enemy.position = start_position_global
	%Creeps.add_child(new_enemy, true)
	new_enemy.destroyed.connect(on_creep_destroyed)
	new_enemy.tree_exited.connect(on_creep_freed)
	new_enemy.process_mode = Node.PROCESS_MODE_INHERIT

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
	var position_is_blocked = (-1 != source_id)
	return position_is_blocked

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
	#ui.show_details("#creeps=" + str(%Creeps.get_child_count()))

	#--- If we've already lost it doesn't matter what the creeps are doing now.
	if CurrentLevel.level_status == CurrentLevel.LevelStatus.LOST:
		return
		
	if (0 == %Creeps.get_child_count()) and (CurrentLevel.level_status == CurrentLevel.LevelStatus.WAVE):
		if CurrentLevel.wave_number == CurrentLevel.wave_number_max:
			CurrentLevel.level_status = CurrentLevel.LevelStatus.WON
			on_win()
		else:
			on_wave_ended()

func on_wave_ended():
	print("wave over, we survived, back to build mode")
	#ui.log("wave done")
	
	wave_end_label.text = "Completion Bonus $%s" % [current_wave.completion_bonus]
	wave_end_message.visible = true
	var tween = fade(wave_end_message, 0, 1, 0.5)
	await tween.finished
	await get_tree().create_timer(message_time_s).timeout
	tween = fade(wave_end_message, 1, 0, 0.5)
	await tween.finished
	wave_end_message.visible = false
	
	show_wave_contents(CurrentLevel.wave_number+1)
	
	#OS.alert("Ain't done this yet, yo", 'Nope')
	#OS.alert("Wave completion bonus: $" + str(current_wave.completion_bonus), "Survived wave " + str(CurrentLevel.wave_number))
	CurrentLevel.level_status = CurrentLevel.LevelStatus.BUILD
	CurrentLevel.money += current_wave.completion_bonus
	# TODO: Show "$ for completing round" message
	ui.show_money()
	%SendWaveButton.disabled = false

func on_creep_reached_base():
	#print("on_creep_reached_base")
	CurrentLevel.base_health -= 1
	ui.show_health()
	if 0 == CurrentLevel.base_health:
		CurrentLevel.level_status = CurrentLevel.LevelStatus.LOST
		on_lose()

func _on_kill_zone_body_entered(body: Node2D):
	#print("kill zone entered by " + str(body))
	if !(body is Creep):
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


###########################################################
# UI Buttons
###########################################################
#region UI Button events
func _on_quit_button_pressed():
	#get_tree().change_scene_to_file("res://menus/level_selection/level_selection.tscn")
	SceneNavigation.go_to_level_manager()

func _on_restart_button_pressed():
	get_tree().reload_current_scene()

func _on_send_wave_button_pressed():
	if CurrentLevel.level_status != CurrentLevel.LevelStatus.BUILD:
		print("Can't send then next wave, we're in status=" + str(CurrentLevel.level_status))
		return
	%SendWaveButton.disabled = true
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
#endregion

#region Tower Info popup events
func _on_sell_button_pressed() -> void:
	var old_money = CurrentLevel.money
	CurrentLevel.money += selected_tower.get_sell_value()
	print("money before=%s, increase=%s, now=%s" % [old_money, selected_tower.get_sell_value(), CurrentLevel.money])
	ui.show_money()
	tower_by_map_coord.erase(selected_tower.position_tile)
	selected_tower.queue_free()
	tower_info_popup_panel.hide()

func _on_upgrade_button_pressed() -> void:
	if selected_tower.level >= selected_tower.max_level:
		print("It can't level any higher. Max="+str(selected_tower.max_level))
		return
	if CurrentLevel.money < selected_tower.cost_per_level:
		print("you can't afford an upgrade. %s vs %s" % [CurrentLevel.money, selected_tower.cost_per_level])
		return
	print("increasing the level")
	selected_tower.increment_level()
	CurrentLevel.money -= selected_tower.cost_per_level
	ui.show_money()
	tower_info_popup_panel.set_info(selected_tower)
#endregion

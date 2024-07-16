extends Node2D

@onready var terrain_tilemap : TileMapLayer = %GroundTileMapLayer
@onready var blocker_tilemap : TileMapLayer = %WallsTileMapLayer
@onready var group_1_start_marker = %StartGroup1
@onready var group_2_start_marker = %StartGroup2
@onready var group_1_end_marker = %EndGroup1
@onready var group_2_end_marker = %EndGroup2
@onready var path_line_1: PathLine = %PathLine1
@onready var path_line_2: PathLine = %PathLine2

var should_show_path := true

var astar_grid = AStarGrid2D.new()

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

var spawn_delay_in_wave_ms : float = 250


func _ready():
	Engine.time_scale = 1

	build_astar_grid()

	group_1_start_coord_global = group_1_start_marker.position
	group_2_start_coord_global = group_2_start_marker.position
	group_1_start_coord_map = coordinate_global_to_map(group_1_start_coord_global)
	group_2_start_coord_map = coordinate_global_to_map(group_2_start_coord_global)
	group_1_end_coord_global = group_1_end_marker.position
	group_2_end_coord_global = group_2_end_marker.position
	group_1_end_coord_map = coordinate_global_to_map(group_1_end_marker.position)
	group_2_end_coord_map = coordinate_global_to_map(group_2_end_marker.position)

	#--- Force the path line to show.
	calculate_default_paths()
	show_default_paths()

func build_astar_grid():
	#print("build_astar_grid")

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
	if event.is_action_pressed("left_click"):
		print_mouse_location()
		#spawn_creep_at(get_global_mouse_position(), group_1_path_global)
	#if event.is_action_pressed("ui_cancel"):
		#get_tree().change_scene_to_file("res://main_menu.tscn")
	#elif event.is_action_pressed("left_click"):
		#plant_tree()
	#elif event.is_action_pressed("right_click"):
		#remove_blocker()

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
	if group_1_path_global.is_empty() or group_2_path_global.is_empty():
		print("no paths so calculating them")
		calculate_default_paths()
		show_default_paths()

	#print("spawn time")
	for i in 5:
		spawn_creep_at(group_1_start_coord_global, group_1_path_global)
		spawn_creep_at(group_2_start_coord_global, group_2_path_global)
		await get_tree().create_timer(spawn_delay_in_wave_ms / 1000).timeout

func spawn_creep_at(start_position_global : Vector2, path : Array[Vector2]):
	#print("spawn_creep_at() global=" + str(start_position_global))
	var new_enemy : PathFollower = %PathFollowerPrototype.duplicate()
	new_enemy.add_to_group("creeps")
	new_enemy.position = start_position_global
	#print("enemy starting at global=" + str(start_position_global) + " map=" + str(coordinate_global_to_map(start_position_global)))
	#print("fucking creep size=" + str(new_enemy.get_size()) + " scale=" + str(new_enemy.transform.get_scale()))
	%Creeps.add_child(new_enemy, true)

	if path.is_empty():
		print("!!! NO PATH FOUND !!! from=" + str(start_position_global))
		new_enemy.queue_free()
	else:
		#--- Path following is destructive so give each agent their own copy of the path.
		new_enemy.follow(path.duplicate())

func coords_map_to_global(coords_map : Array[Vector2i]) -> Array[Vector2]:
	var coords_global : Array[Vector2] = []
	for coord_map in coords_map:
		var coord_global = coordinate_map_to_global(coord_map)
		coords_global.push_back(coord_global)
	return coords_global

func coords_map_to_global_old(list : Array[Vector2i]) -> Array[Vector2]:
	#--- The word "map" is used for levels, TileMaps, hash tables and collection map/reduce functions. Ugh.
	#--- GDSscript Array.map() doesn't work with types so we use this hack.
	var coords_local  : Array[Vector2] = []
	coords_local.assign(list.map(terrain_tilemap.map_to_local))
	#--- Or we could stop using stupid "functional" programming and do it the supportable way.
	var coords_global : Array[Vector2] = []
	for coord_local in coords_local:
		var coord_global = to_global(coord_local)
		coords_global.push_back(coord_global)
	return coords_global

func coordinate_global_to_map(coordinate_global : Vector2i) -> Vector2i:
	var coordinate_local = to_local(coordinate_global)
	var coordinate_map   = terrain_tilemap.local_to_map(coordinate_local)
	return coordinate_map

func coordinate_map_to_global(coordinate_map : Vector2i) -> Vector2:
	var coordinate_local  = terrain_tilemap.map_to_local(coordinate_map)
	var coordinate_global = to_global(coordinate_local)
	return coordinate_global

func _on_kill_zone_body_entered(body: Node2D):
	if body is PathFollower:
		body.queue_free()

func _on_quit_button_pressed():
	get_tree().change_scene_to_file("res://menus/level_selection/level_selection.tscn")

func _on_send_wave_button_pressed():
	spawn_creeps()

func _on_speed_half_button_pressed() -> void:
	Engine.time_scale = 0.5

func _on_speed_normal_button_pressed() -> void:
	Engine.time_scale = 1

func _on_speed_2_button_pressed() -> void:
	Engine.time_scale = 2

func _on_speed_5_button_pressed() -> void:
	Engine.time_scale = 5

extends LevelData

func _ready() -> void:
	setup_paths()

func setup_paths():
	var path := Path.new()
	path_by_name[path.name] = path
	path.start_coord_map = coordinate_global_to_map(%StartGroup1.position)
	path.end_coord_map   = coordinate_global_to_map(%EndGroup1.position)
	#path.kill_zone       = %EndGroup1.KillZone
	path.kill_zone       = %EndGroup1.get_node("KillZone")

	path = Path.new()
	path.name = "path_2"
	path_by_name[path.name] = path
	path.start_coord_map = coordinate_global_to_map(%StartGroup2.position)
	path.end_coord_map   = coordinate_global_to_map(%EndGroup2.position)
	path.kill_zone       = %EndGroup2.get_node("KillZone")

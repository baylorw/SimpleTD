extends LevelData

func _ready() -> void:
	setup_paths()

func setup_paths():
	var path := Path.new()
	path.name = "path_1"
	path_by_name[path.name] = path
	path.start_coord_map = coordinate_global_to_map(%StartGroup1.position)
	path.end_coord_map   = coordinate_global_to_map(%EndPoint.position)
	path.kill_zone       = %KillZone

	path = Path.new()
	path.name = "path_2"
	path_by_name[path.name] = path
	path.start_coord_map = coordinate_global_to_map(%StartGroup2.position)
	path.end_coord_map   = coordinate_global_to_map(%EndPoint.position)
	path.kill_zone       = %KillZone

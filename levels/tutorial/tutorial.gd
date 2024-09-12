extends LevelData

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

func setup_waves():
	waves.push_back(create_uniform_wave(2, "weak",   20, 1))
	waves.push_back(create_uniform_wave(2, "weak",   20, 2))
	waves.push_back(create_uniform_wave(2, "normal", 20, 3))
	waves.push_back(create_uniform_wave(2, "fast",   20, 4, 0.25))
	waves.push_back(create_uniform_wave(2, "tough",  10, 5, 1))
	waves.push_back(create_uniform_wave(2, "weak",   20, 6))
	waves.push_back(create_uniform_wave(2, "weak",   20, 7))
	waves.push_back(create_uniform_wave(2, "normal", 20, 8))
	waves.push_back(create_uniform_wave(2, "fast",   20, 9, 0.25))
	waves.push_back(create_uniform_wave(2, "tough",  10, 10, 1))
	waves.push_back(create_uniform_wave(2, "weak",   20, 11))
	waves.push_back(create_uniform_wave(2, "weak",   20, 12))
	waves.push_back(create_uniform_wave(2, "normal", 20, 13))
	waves.push_back(create_uniform_wave(2, "fast",   20, 14, 0.25))
	waves.push_back(create_uniform_wave(2, "tough",  10, 15, 1))
	waves.push_back(create_uniform_wave(2, "weak",   20, 16))
	waves.push_back(create_uniform_wave(2, "weak",   20, 17))
	waves.push_back(create_uniform_wave(2, "normal", 20, 18))
	waves.push_back(create_uniform_wave(2, "fast",   20, 19, 0.25))
	waves.push_back(create_uniform_wave(2, "tough",  10, 20, 1))

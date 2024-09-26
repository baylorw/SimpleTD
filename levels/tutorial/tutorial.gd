extends LevelData

func setup_paths():
	var path := Path.new()
	path.name = "path_1"
	path_by_name[path.name] = path
	path.start_coord_map = coordinate_global_to_map(%StartGroup.position)
	path.end_coord_map   = coordinate_global_to_map(%EndGroup.position)
	path.kill_zone       = %KillZone

func setup_waves():
	waves.push_back(create_uniform_wave(1, "weak", 3, 1))
	waves.push_back(create_uniform_wave(1, "weak", 3, 1))
	waves.push_back(create_uniform_wave(1, "fast", 5, 2))
	waves.push_back(create_uniform_wave(1, "fast", 5, 2))
	waves.push_back(create_uniform_wave(1, "normal", 5, 3))
	waves.push_back(create_uniform_wave(1, "chicken", 5, 4))

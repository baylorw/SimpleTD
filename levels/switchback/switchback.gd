extends LevelData

func setup_paths():
	var path := Path.new()
	path.name = "path_1"
	path_by_name[path.name] = path
	path.start_coord_map = coordinate_global_to_map(%StartGroup1.position)
	path.end_coord_map   = coordinate_global_to_map(%EndGroup1.position)
	path.kill_zone       = %KillZone

	path = Path.new()
	path.name = "path_2"
	path_by_name[path.name] = path
	path.start_coord_map = coordinate_global_to_map(%StartGroup2.position)
	path.end_coord_map   = coordinate_global_to_map(%EndGroup2.position)
	path.kill_zone       = %KillZone

func setup_waves():
	waves.push_back(create_uniform_wave(2, "weak_1", 5))
	waves.push_back(create_uniform_wave(2, "weak_1", 10))
	waves.push_back(create_uniform_wave(2, "normal_1", 5))
	waves.push_back(create_uniform_wave(2, "normal_1", 10))
	var wave = create_uniform_wave(2, "fast_1", 10)
	wave.time_between_creeps_sec = 0.25
	waves.push_back(wave)

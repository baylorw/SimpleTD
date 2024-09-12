extends LevelData

func setup_paths():
	var path := Path.new()
	path.name = "path_1"
	path_by_name[path.name] = path
	path.start_coord_map = coordinate_global_to_map(%StartGroup1.position)
	path.end_coord_map   = coordinate_global_to_map(%EndGroup1.position)
	path.kill_zone       = %EndGroup1.get_node("KillZone")

func setup_waves():
	var wave = Wave.new()
	waves.push_back(wave)
	var path_wave = PathWave.new()
	wave.wave_by_path["path_1"] = path_wave
	add_creep_to_path_wave(path_wave, "weak", 3, 1)
	add_creep_to_path_wave(path_wave, "normal", 2, 2)
	add_creep_to_path_wave(path_wave, "tough", 1, 3)
	add_creep_to_path_wave(path_wave, "fast", 5, 4)
	add_creep_to_path_wave(path_wave, "weak", 3, 5)
	add_creep_to_path_wave(path_wave, "normal", 2, 6)
	add_creep_to_path_wave(path_wave, "tough", 1, 7)
	add_creep_to_path_wave(path_wave, "fast", 4, 8)
	add_creep_to_path_wave(path_wave, "chicken", 1, 9)
	add_creep_to_path_wave(path_wave, "no-op", 3)
	add_creep_to_path_wave(path_wave, "chicken", 1, 10)
	add_creep_to_path_wave(path_wave, "no-op", 3)
	add_creep_to_path_wave(path_wave, "chicken", 1, 11)

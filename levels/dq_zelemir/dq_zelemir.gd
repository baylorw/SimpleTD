extends LevelData

#func _ready() -> void:
	#setup_paths()
	#setup_waves()

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

	path = Path.new()
	path.name = "path_3"
	path_by_name[path.name] = path
	path.start_coord_map = coordinate_global_to_map(%StartGroup3.position)
	path.end_coord_map   = coordinate_global_to_map(%EndPoint.position)
	path.kill_zone       = %KillZone

func setup_waves():
	#--- Wave 1: Center path, 3 weak creeps
	var wave = Wave.new()
	waves.push_back(wave)
	var path_wave = PathWave.new()
	wave.wave_by_path["path_2"] = path_wave
	add_creep_to_path_wave(path_wave, "weak_1", 3)
	
	#--- Wave 2: Outer paths, 5 weak creeps
	wave = Wave.new()
	waves.push_back(wave)
	path_wave = PathWave.new()
	wave.wave_by_path["path_1"] = path_wave
	add_creep_to_path_wave(path_wave, "weak_1", 5)
	wave.wave_by_path["path_3"] = path_wave
	add_creep_to_path_wave(path_wave, "weak_1", 5)
	
	#--- Wave 3: All 3 paths, 10 creeps, weak on sides, regular in center
	wave = Wave.new()
	waves.push_back(wave)
	path_wave = PathWave.new()
	wave.wave_by_path["path_1"] = path_wave
	add_creep_to_path_wave(path_wave, "normal_1", 10)
	path_wave = PathWave.new()
	wave.wave_by_path["path_2"] = path_wave
	add_creep_to_path_wave(path_wave, "fast", 10)
	path_wave = PathWave.new()
	wave.wave_by_path["path_3"] = path_wave
	add_creep_to_path_wave(path_wave, "normal_1", 10)
	
	#--- Wave 4: All 3 paths
	wave = Wave.new()
	waves.push_back(wave)
	path_wave = PathWave.new()
	wave.wave_by_path["path_1"] = path_wave
	add_creep_to_path_wave(path_wave, "tough_slow_1", 10)
	path_wave = PathWave.new()
	wave.wave_by_path["path_3"] = path_wave
	add_creep_to_path_wave(path_wave, "normal_1", 10)
	path_wave = PathWave.new()
	wave.wave_by_path["path_2"] = path_wave
	add_creep_to_path_wave(path_wave, "fast", 1)
	add_creep_to_path_wave(path_wave, "chicken", 1)
	add_creep_to_path_wave(path_wave, "fast", 1)
	add_creep_to_path_wave(path_wave, "chicken", 1)
	add_creep_to_path_wave(path_wave, "fast", 1)
	add_creep_to_path_wave(path_wave, "chicken", 1)
	add_creep_to_path_wave(path_wave, "fast", 1)
	add_creep_to_path_wave(path_wave, "chicken", 1)
	add_creep_to_path_wave(path_wave, "fast", 1)
	add_creep_to_path_wave(path_wave, "chicken", 1)

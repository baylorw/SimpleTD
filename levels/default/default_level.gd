extends LevelData

func _ready() -> void:
	super._ready()

func setup_paths():
	var path := Path.new()
	path.name = "path_1"
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

	path = Path.new()
	path.name = "path_3"
	path_by_name[path.name] = path
	path.start_coord_map = coordinate_global_to_map(%StartGroup3.position)
	path.end_coord_map   = coordinate_global_to_map(%EndGroup3.position)
	path.kill_zone       = %EndGroup3.get_node("KillZone")

	path = Path.new()
	path.name = "path_4"
	path_by_name[path.name] = path
	path.start_coord_map = coordinate_global_to_map(%StartGroup4.position)
	path.end_coord_map   = coordinate_global_to_map(%EndGroup4.position)
	path.kill_zone       = %EndGroup4.get_node("KillZone")

func setup_waves():
	var wave = Wave.new()
	waves.push_back(wave)
	#wave.time_between_creeps_sec = 1
	var path_wave = PathWave.new()
	wave.wave_by_path["path_1"] = path_wave
	add_creep_to_path_wave(path_wave, "weak", 5)
	add_creep_to_path_wave(path_wave, "normal", 10, 2)
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
	add_creep_to_path_wave(path_wave, "chicken", 1, 9)
	add_creep_to_path_wave(path_wave, "no-op", 3)
	add_creep_to_path_wave(path_wave, "chicken", 1, 9)
	
	wave = Wave.new()
	waves.push_back(wave)
	path_wave = PathWave.new()
	wave.wave_by_path["path_2"] = path_wave
	add_creep_to_path_wave(path_wave, "normal", 5, 2)
	
	wave = Wave.new()
	waves.push_back(wave)
	path_wave = PathWave.new()
	wave.wave_by_path["path_3"] = path_wave
	add_creep_to_path_wave(path_wave, "fast", 5, 3)

	wave = Wave.new()
	waves.push_back(wave)
	path_wave = PathWave.new()
	wave.wave_by_path["path_4"] = path_wave
	add_creep_to_path_wave(path_wave, "tough", 5, 4)

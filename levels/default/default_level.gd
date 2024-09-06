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
	var path_wave = PathWave.new()
	wave.wave_by_path["path_1"] = path_wave
	#add_creep_to_path_wave(path_wave, "weak_1", 5)
	#add_creep_to_path_wave(path_wave, "normal_1", 10, 2)
	#wave.time_between_creeps_sec = 1
	add_creep_to_path_wave(path_wave, "weak", 1, 1)
	add_creep_to_path_wave(path_wave, "normal", 1, 2)
	add_creep_to_path_wave(path_wave, "tough", 1, 3)
	add_creep_to_path_wave(path_wave, "fast", 1, 4)
	add_creep_to_path_wave(path_wave, "weak", 1, 5)
	add_creep_to_path_wave(path_wave, "normal", 1, 6)
	add_creep_to_path_wave(path_wave, "tough", 1, 7)
	add_creep_to_path_wave(path_wave, "fast", 1, 8)
	
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

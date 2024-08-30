extends LevelData

func _ready() -> void:
	setup_paths()
	setup_waves()

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
	add_creep_to_path_wave(path_wave, "weak_1", 5)
	
	wave = Wave.new()
	waves.push_back(wave)
	path_wave = PathWave.new()
	wave.wave_by_path["path_2"] = path_wave
	add_creep_to_path_wave(path_wave, "weak_1", 5)
	
	wave = Wave.new()
	waves.push_back(wave)
	path_wave = PathWave.new()
	wave.wave_by_path["path_3"] = path_wave
	add_creep_to_path_wave(path_wave, "weak_1", 5)

	wave = Wave.new()
	waves.push_back(wave)
	path_wave = PathWave.new()
	wave.wave_by_path["path_4"] = path_wave
	add_creep_to_path_wave(path_wave, "weak_1", 5)
	
func add_creep_to_path_wave(path_wave: PathWave, creep_name: String, count: int):
	for i in count:
		path_wave.creeps.push_back(creep_name)

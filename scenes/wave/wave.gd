class_name Wave extends Node

## {path.name: PathWave}
var wave_by_path := {}
var time_between_creeps_sec := 0.5
var completion_bonus := 100

func max_wave_ticks() -> int:
	var max_val = 0
	for path_wave in wave_by_path.values():
		if path_wave.creeps.size() > max_val:
			max_val = path_wave.creeps.size()
	return max_val

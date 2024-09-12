class_name LevelData extends Node2D

@onready var terrain_tilemap : TileMapLayer = %GroundTileMapLayer
@onready var blockers_tilemap : TileMapLayer = %WallsTileMapLayer

#@onready var border_size_ddlb: OptionButton = %BorderSizeDDLB

var path_by_name := {}
var waves : Array[Wave] = []

@export var starting_money := 275
var allowed_towers : Array[String] = []


func _ready() -> void:
	setup_paths()
	setup_waves()

# CHILDREN MUST OVERRIDE 
func setup_paths():
	pass
func setup_waves():
	pass
 

func create_uniform_wave(number_of_paths: int, creep_name: String, number_per_path: int, level:=1, time_between_creeps_s: float=-1) -> Wave:
	var wave = Wave.new()
	if time_between_creeps_s > 0:
		wave.time_between_creeps_sec = time_between_creeps_s
	for path_number in number_of_paths:
		var path_name = "path_" + str(path_number+1)
		var path_wave = PathWave.new()
		wave.wave_by_path[path_name] = path_wave
		add_creep_to_path_wave(path_wave, creep_name, number_per_path, level)
	return wave

func add_creep_to_path_wave(path_wave: PathWave, creep_name: String, count: int, level:=1):
	for i in count:
		var creep = CreepSpecifier.new(creep_name, level)
		path_wave.creeps.push_back(creep)

###########################################################
# Util functions needed by child classes
###########################################################
func coordinate_global_to_map(coordinate_global : Vector2) -> Vector2i:
	var coordinate_local = to_local(coordinate_global)
	var coordinate_map   = terrain_tilemap.local_to_map(coordinate_local)
	return coordinate_map

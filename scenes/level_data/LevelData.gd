class_name LevelData extends Node2D

@onready var terrain_tilemap : TileMapLayer = %GroundTileMapLayer
@onready var blockers_tilemap : TileMapLayer = %WallsTileMapLayer

#@onready var border_size_ddlb: OptionButton = %BorderSizeDDLB

var path_by_name := {}
var waves : Array[Wave] = []


###########################################################
# Util functions needed by child classes
###########################################################
func coordinate_global_to_map(coordinate_global : Vector2) -> Vector2i:
	var coordinate_local = to_local(coordinate_global)
	var coordinate_map   = terrain_tilemap.local_to_map(coordinate_local)
	return coordinate_map

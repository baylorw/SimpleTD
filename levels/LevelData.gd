class_name LevelData extends Node

@onready var terrain_tilemap : TileMapLayer = %GroundTileMap
@onready var blockers_tilemap : TileMapLayer = %WallsTileMap
@onready var shade_tile_map: TileMapLayer = %ShadeTileMap
@onready var tile_borders_tile_map: TileMapLayer = %TileBordersTileMap
@onready var path_tile_map: TileMapLayer = %PathTileMap
@onready var annotations_tile_map: TileMapLayer = %AnnotationsTileMap
@onready var towers_tilemap : TileMapLayer = %TowersTileMap

#@onready var border_size_ddlb: OptionButton = %BorderSizeDDLB

class_name Path extends Node

#--- Start point in tile map (not global) coordinates
var start_coord_map : Vector2i
var end_coord_map   : Vector2i

#--- These parts are filled in by the level manager
var display : PathLine
var start_coord_global : Vector2
var end_coord_global   : Vector2
var waypoints_global : Array[Vector2] = []

#--- 
var kill_zone: Area2D 

extends Node

func go_to_main_menu():
	get_tree().change_scene_to_file("res://menus/main/main_menu.tscn")

func go_to_level_manager():
	get_tree().change_scene_to_file("res://menus/level_selection/level_selection.tscn")

func go_to_level(level_name: String):
	Globals.level_name = "res://levels/%s/%s.tscn" % [level_name, level_name]
	get_tree().change_scene_to_file("res://scenes/level_manager/level_manager.tscn")

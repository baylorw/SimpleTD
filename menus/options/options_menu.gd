extends Node2D

func _ready() -> void:
	Music.stop()
	
func _on_quit_button_pressed():
	Music.stop()
	get_tree().change_scene_to_file("res://menus/main/main_menu.tscn")

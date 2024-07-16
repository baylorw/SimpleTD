extends Control

func _on_new_game_button_pressed():
	get_tree().change_scene_to_file("res://menus/level_selection/level_selection.tscn")

func _on_options_button_pressed():
	get_tree().change_scene_to_file("res://menus/options/options_menu.tscn")

func _on_quit_button_pressed():
	get_tree().quit()

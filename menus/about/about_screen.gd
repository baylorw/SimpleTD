extends Control

func _on_quit_button_pressed():
	Music.stop()
	SceneNavigation.go_to_main_menu()

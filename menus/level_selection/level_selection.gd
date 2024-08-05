extends Control

const grayed_out_color := Color("48484888")


func _ready():
	for control in $CanvasLayer/LevelsContainer.get_children():
		if control is TextureButton and control.disabled:
			#--- Couldn't find a named version of gray that looked right
			control.modulate = grayed_out_color

func _on_quit_button_pressed():
	get_tree().change_scene_to_file("res://menus/main/main_menu.tscn")

func _on_level_1_button_pressed():
	Globals.level_name = "res://levels/void/void.tscn"
	get_tree().change_scene_to_file("res://scenes/level/level.tscn")
	#OS.alert("Ain't done this yet, yo", 'Nope')
	#alert("This isn't implemented yet", "TBD")

func _on_level_2_button_pressed():
	Globals.level_name = "res://levels/frog/frog.tscn"
	get_tree().change_scene_to_file("res://scenes/level/level.tscn")

func _on_level_3_button_pressed():
	Globals.level_name = "res://levels/elementalish/elementalish.tscn"
	get_tree().change_scene_to_file("res://scenes/level/level.tscn")

func _on_level_4_button_pressed():
	Globals.level_name = "res://levels/no_left_turns/no_left_turns.tscn"
	get_tree().change_scene_to_file("res://scenes/level/level.tscn")

func _on_texture_button_5_pressed() -> void:
	Globals.level_name = "res://levels/slim_pickings/slim_pickings.tscn"
	get_tree().change_scene_to_file("res://scenes/level/level.tscn")

func _on_texture_button_6_pressed() -> void:
	Globals.level_name = "res://levels/snaking_path/snaking_path.tscn"
	get_tree().change_scene_to_file("res://scenes/level/level.tscn")

func _on_texture_button_7_pressed() -> void:
	Globals.level_name = "res://levels/switchback/switchback.tscn"
	get_tree().change_scene_to_file("res://scenes/level/level.tscn")

func _on_texture_button_8_pressed() -> void:
	Globals.level_name = "res://levels/up_and_down/up_and_down.tscn"
	get_tree().change_scene_to_file("res://scenes/level/level.tscn")


## This works but wipes out your level when it's done.
func alert(text: String, title: String='Message'):
	var dialog = AcceptDialog.new()
	dialog.dialog_text = text
	dialog.title = title
	#dialog.connect(dialog, "canceled", queue_free)
	#dialog.confirmed.connect(dialog, queue_free)
	add_child(dialog)
	dialog.popup_centered()

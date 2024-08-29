extends Control

const grayed_out_color := Color("48484888")

var level_name_by_id := {
	"elementalish": "Elementalish",
	"frog": "Frog",
	"dq_halls_of_the_god_king": "God King",
	"no_left_turns": "No Left Turns",
	"slim_pickings": "Slim Pickings",
	"snaking_path": "Snaking Path",
	"switchback": "Switchback",
	"up_and_down": "Up And Down",
	"void": "Void"
}
var current_level : String

func _ready():
	#for control in %LevelsContainer.get_children():
		#if control is TextureButton:
			#var level_name = control.get_meta("level_name")
			#if !level_name:
				#print("No level defined for " + control.name)
				#control.disabled = true
			#control.pressed.connect(Callable(_on_level_selection_button_pressed).bind(level_name))
		#if control is TextureButton and control.disabled:
			##--- Couldn't find a named version of gray that looked right
			#control.modulate = grayed_out_color
			
	setup_level_buttons()

func setup_level_buttons():
	#--- This button helps when designing the screen to see how much room stuff takes.
	#--- But we don't want to show it at runtime.
	%PlaceholderButton.free()
	
	level_name_by_id.keys().sort()
	for id in level_name_by_id.keys():
		var button = Button.new()
		var display_name = level_name_by_id[id]
		button.name = display_name + "Button"
		button.text = display_name
		button.set_meta("level_name", id)
		button.pressed.connect(Callable(_on_level_selection_button_pressed).bind(id))
		%ButtonVBoxContainer.add_child(button)

func _on_quit_button_pressed():
	get_tree().change_scene_to_file("res://menus/main/main_menu.tscn")

#func _on_level_1_button_pressed():
	##Globals.level_name = "res://levels/void/void.tscn"
	##get_tree().change_scene_to_file("res://scenes/level/level.tscn")
	#SceneNavigation.go_to_level("void")
#
#func _on_level_2_button_pressed():
	##Globals.level_name = "res://levels/frog/frog.tscn"
	##get_tree().change_scene_to_file("res://scenes/level/level.tscn")
	#SceneNavigation.go_to_level("frog")
#
#func _on_level_3_button_pressed():
	##Globals.level_name = "res://levels/elementalish/elementalish.tscn"
	##get_tree().change_scene_to_file("res://scenes/level/level.tscn")
	#SceneNavigation.go_to_level("elementalish")
#
#func _on_level_4_button_pressed():
	##Globals.level_name = "res://levels/no_left_turns/no_left_turns.tscn"
	##get_tree().change_scene_to_file("res://scenes/level/level.tscn")
	#SceneNavigation.go_to_level("no_left_turns")
#
#func _on_texture_button_5_pressed() -> void:
	##Globals.level_name = "res://levels/slim_pickings/slim_pickings.tscn"
	##get_tree().change_scene_to_file("res://scenes/level/level.tscn")
	#SceneNavigation.go_to_level("slim_pickings")
#
#func _on_texture_button_6_pressed() -> void:
	##Globals.level_name = "res://levels/snaking_path/snaking_path.tscn"
	##get_tree().change_scene_to_file("res://scenes/level/level.tscn")
	#SceneNavigation.go_to_level("snaking_path")
#
#func _on_texture_button_7_pressed() -> void:
	##Globals.level_name = "res://levels/switchback/switchback.tscn"
	##get_tree().change_scene_to_file("res://scenes/level/level.tscn")
	#SceneNavigation.go_to_level("switchback")
#
#func _on_texture_button_8_pressed() -> void:
	##Globals.level_name = "res://levels/up_and_down/up_and_down.tscn"
	##get_tree().change_scene_to_file("res://scenes/level/level.tscn")
	#SceneNavigation.go_to_level("up_and_down")

func _on_level_selection_button_pressed(level_name : String):
	print("_on_level_selection_button_pressed=" + level_name)
	SceneNavigation.go_to_level(level_name)


# TODO: Fix the alert window
## This works but wipes out your level when it's done.
func alert(text: String, title: String='Message'):
	#OS.alert("Ain't done this yet, yo", 'Nope')
	#alert("This isn't implemented yet", "TBD")

	var dialog = AcceptDialog.new()
	dialog.dialog_text = text
	dialog.title = title
	#dialog.connect(dialog, "canceled", queue_free)
	#dialog.confirmed.connect(dialog, queue_free)
	add_child(dialog)
	dialog.popup_centered()

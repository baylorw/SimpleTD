class_name TutorialManager extends Node

#@export var level_mananger : LevelManager
@onready var level_manager: TutorialLevelManager = $".."
@onready var tutorial_step_manager: TutorialStepManager = %TutorialStepManager
@onready var ui: LevelUI = %UI
#@onready var tutorial_canvas_layer: CanvasLayer = %TutorialCanvasLayer
@onready var tutorial_image: TextureRect = %TutorialImage

@onready var shade: TextureRect = %Shade
@onready var highlight_arrow: TextureRect = %HighlightArrow
@onready var tutorial_dialog: TutorialDialogWindow = %TutorialDialog
@onready var tutorial_label: Label = %TutorialLabel

var arrow_offset := Vector2(10, -10)
#var highlight_offset_uv := 0.005
var highlight_offset_uv := 0.00

#var tutorial_step := 0
#var dialogue_step := 0
#const DIALOGUES: Dictionary = {
	#"0" = {
		#"0" = "Hi and welcome to the tutorial! Everyone LOVES tutorials! LOOOOOVES them.",
		#"1" = "Let's just start. Press the Send Wave button.",
	 #},
	#"1" = {
		#"0" = "You lost!",
		#"1" = "Now let's do the next thing",
	 #},
	#"2" = {
		#"0" = "Creeps come from here",
		#"1" = "xxx",
	 #},
	#"3" = {
		#"0" = "Creeps go here",
		#"1" = "In this step, let's do this thing.",
	 #},
	#"4" = {
		#"0" = "Here are your lives",
		#"1" = "In this step, let's do this thing.",
	 #},
	#"5" = {
		#"0" = "Press play",
		#"1" = "In this step, let's do this thing.",
	 #},
	#"6" = {
		#"0" = "Here is your money",
		#"1" = "In this step, let's do this thing.",
	 #},
	#"7" = {
		#"0" = "Mouse over towers",
		#"1" = "In this step, let's do this thing.",
	 #}, 
	#"8" = {
		#"0" = "Buy a tower",
		#"1" = "In this step, let's do this thing.",
	 #},
	#"9" = {
		#"0" = "Place it here",
		#"1" = "In this step, let's do this thing.",
	 #},
	#"10" = {
		#"0" = "Press play again",
		#"1" = "In this step, let's do this thing.",
	 #},
	#"11" = {
		#"0" = "You win!",
		#"1" = "In this step, let's do this thing.",
	 #},
	#"12" = {
		#"0" = "This wave number says how many waves",
		#"1" = "In this step, let's do this thing.",
	 #},
	#"13" = {
		#"0" = "Press play ",
		#"1" = "In this step, let's do this thing.",
	 #},
	#"14" = {
		#"0" = "They're too fast! ",
		#"1" = "In this step, let's do this thing.",
	 #},
	#"15" = {
		#"0" = "You can now afford a blue. Place it here",
		#"1" = "In this step, let's do this thing.",
	 #},
	#"16" = {
		#"0" = "Press play ",
		#"1" = "In this step, let's do this thing.",
	 #},
	#"17" = {
		#"0" = "This is the wave preview. They're stronger so you need more towers",
		#"1" = "In this step, let's do this thing.",
	 #},
	#"18" = {
		#"0" = "Upgrade this tower",
		#"1" = "In this step, let's do this thing.",
	 #},
	#"19" = {
		#"0" = "Press play",
		#"1" = "In this step, let's do this thing.",
	 #},
	#"20" = {
		#"0" = "You win!",
		#"1" = "In this step, let's do this thing.",
	 #},
	#"21" = {
		#"0" = "Press quit",
		#"1" = "In this step, let's do this thing.",
	 #}
#}


func _ready() -> void:
	disable_all_buttons()
	tutorial_image.hide()
	Events.level_loaded.connect(on_level_loaded)

func on_level_loaded():
	print("on_level_loaded")
	tutorial_step_manager.start()

func disable_all_buttons():
	ui.should_suppress_affordable_towers = true
	ui.disable_all_buttons()
func enable_all_buttons():
	ui.should_suppress_affordable_towers = false
	ui.enable_all_buttons()

func hide_tutorial_stuff():
	tutorial_image.hide()
	shade.hide()
	highlight_arrow.hide()
	tutorial_dialog.hide()
	enable_all_buttons()

func show_dialog(lines: Array[String], show_final_continue:=true) -> void:
	tutorial_dialog.show_lines(lines, show_final_continue)
	tutorial_dialog.show()
	#tutorial_label.text = DIALOGUES[tutorial_step][dialogue_step]

func show_image(texture: Texture):
	tutorial_image.texture = texture
	tutorial_image.show()


#func _on_next_dialogue_pressed() -> void:
	#dialogue_step += 1
	#show_dialogue()

#func _on_progress_tutorial_pressed() -> void:
	#tutorial_step += 1
	#dialogue_step = 0
	##anim_player.play("tutorial_" + str(tutorial_step))
	#show_dialogue()

#func do_tutorial():
	#match tutorial_step:
		#1: 
			#get_tree().paused = true
			#shade.visible = true
			#tutorial_label.text = "Let's learn how to play this game!"
			#tutorial_dialog.visible = true
		#2: 
			#get_tree().paused = false
			#shade.visible = true
			#highlight(%SendWaveButton)
			#tutorial_label.text = "Press the Send Wave button."
			#tutorial_dialog.visible = true
		#3: 
			##--- Do nothing. Wait for the player to press Send Wave.
			##--- Actually, wait for them to lose. 
			#pass
		#4: 
			#get_tree().paused = true
			#shade.visible = false
			#tutorial_label.text = "Oh no! You lost!"
			#tutorial_dialog.visible = true
		#_:
			#get_tree().paused = true
			#shade.visible = true
			#highlight(%QuitButton)
			#tutorial_label.text = "Press Quit to go back to the level selection menu."
			#tutorial_dialog.visible = true
			#get_tree().paused = false
			#
	#tutorial_step += 1
	
func dim_screen():
	disable_all_buttons()
	shade.visible = true

func highlight(object):
	disable_all_buttons()
	if (object is Button) or (object is TextureButton):
		object.disabled = false
	
	#print("NOTICE: object=%s position=%s global=%s screen=%s" % \
		#[object, object.position, object.global_position, object.get_screen_position()])
	
	highlight_arrow.visible = true
	if object.global_position.x < 50:
		highlight_arrow.position = get_top_right_corner(object)
		highlight_arrow.flip_h = true
	else:
		highlight_arrow.position = object.global_position - arrow_offset
		highlight_arrow.flip_h = false
	shade.visible = true
	var top_left     = global_to_uv(object.global_position)
	var bottom_right = global_to_uv(object.global_position + object.size)
	shade.material.set_shader_parameter("tlx", top_left.x-highlight_offset_uv)
	shade.material.set_shader_parameter("tly", top_left.y-highlight_offset_uv)
	shade.material.set_shader_parameter("brx", bottom_right.x+highlight_offset_uv)
	shade.material.set_shader_parameter("bry", bottom_right.y+highlight_offset_uv)

#region Coordinate functions
func global_to_uv(coord_global: Vector2) -> Vector2:
	return coord_global / get_viewport().get_visible_rect().size

func get_top_right_corner(object) -> Vector2:
	return object.global_position + Vector2(object.size.x, 0)
#endregion

#func _on_continue_button_pressed() -> void:
	#tutorial_dialog.hide()
	#do_tutorial()

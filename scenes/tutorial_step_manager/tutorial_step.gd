class_name TutorialStep extends Node

signal finished(step_name: String)

var tutorial_manager: TutorialManager
@export var signal_name_to_wait_for : String= "dialog_finished"
#@export var signal_argument : String

@export var highlight_item : Node
## Ignored if Highlight Item is enabled.
@export var hide_everything := false
## Ignored if Highight Item or Everything is enabled.
@export var disable_buttons := false
@export_multiline var dialog_lines : Array[String]
@export var image_to_show : Texture


func enter(new_tutorial_manager: TutorialManager) -> void:
	self.tutorial_manager = new_tutorial_manager
	print("Starting state=" + name)
	if signal_name_to_wait_for:
		Events.connect(signal_name_to_wait_for, on_wait_finished)
		
	if highlight_item:
		tutorial_manager.highlight(highlight_item)
	elif hide_everything:
		tutorial_manager.dim_screen()
	elif disable_buttons:
		tutorial_manager.disable_all_buttons()

	if dialog_lines and !dialog_lines.is_empty():
		var should_show_final_continue := (signal_name_to_wait_for == "dialog_finished")
		tutorial_manager.show_dialog(dialog_lines, should_show_final_continue)
	
	if image_to_show:
		tutorial_manager.show_image(image_to_show)

func on_wait_finished():
	#print("on_wait_finished arg=" + argument)
	#if signal_argument and (argument != signal_argument):
		#print("Wrong signal=" + argument)
		#return
		
	#--- These steps don't disappear/get freed, so when a signal is fired 
	#---	they still get it and reply. So DialogFinished is captured 
	#---	and echoed as on_wait_finished once after the first step, 
	#---	twice on the next, 3x on the third, etc.
	#--- If we don't want dup events/event storms then we need to disconnect.
	Events.disconnect(signal_name_to_wait_for, on_wait_finished)

	print_debug("on_wait_finished for " + self.name +". Firing finished event.")
	emit_signal("finished", self.name)
	
func exit() -> void:
	pass
	
#func handle_input(_event: InputEvent) -> void:
#func physics_update(_delta: float) -> void:
#func update(_delta: float) -> void:

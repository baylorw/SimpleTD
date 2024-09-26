class_name TutorialDialogWindow extends MarginContainer

#signal dialog_finished

@onready var tutorial_label: Label = %TutorialLabel
@onready var continue_button: Button = %ContinueButton
@onready var buttons_container: HBoxContainer = %ButtonsContainer

var should_show_final_continue := true
var lines : Array[String]= []

func show_lines(new_lines: Array[String], show_final_continue:=true):
	self.should_show_final_continue = show_final_continue
	self.lines = new_lines
	print("show_lines() called with %s lines and show Continue=%s" % [new_lines.size(), should_show_final_continue])
	var first_line = lines.pop_front()
	tutorial_label.text = first_line
	
	if lines.is_empty() and !should_show_final_continue:
		buttons_container.hide()
	else:
		buttons_container.show()

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		_on_quit_button_pressed()

func _on_quit_button_pressed() -> void:
	SceneNavigation.go_to_level_manager()
	
func _on_continue_button_pressed() -> void:
	if lines.is_empty():
		Events.dialog_finished.emit()
	else:
		var line = lines.pop_front()
		tutorial_label.text = line
		if lines.is_empty():
			if !should_show_final_continue:
				buttons_container.hide()

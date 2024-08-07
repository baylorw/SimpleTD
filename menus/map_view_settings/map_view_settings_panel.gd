extends PopupPanel

#func _ready():
	#--- Why is this not a config option in Inspector? Or just built into popup()?
	#--- Nevermind. It doesn't work.
	#self.exclusive = true

func _on_about_to_popup() -> void:
	get_tree().paused = true

func _on_close_button_pressed() -> void:
	self.hide()

func _on_popup_hide() -> void:
	get_tree().paused = false

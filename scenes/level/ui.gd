class_name LevelUI extends CanvasLayer

func show_health():
	%HealthLabel.text = "Health: %s/%s" % [CurrentLevel.base_health, CurrentLevel.base_health_max]

func show_money():
	%MoneyLabel.text = "Money: %s" % [CurrentLevel.money]

func show_wave():
	%WaveLabel.text = "Wave: %s/%s" % [CurrentLevel.wave_number, CurrentLevel.wave_number_max]

func show_details(message: String):
	%DetailsLabel.text = message

func log(message: String):
	%DetailsLabel.text += "\n" + message


func _on_blue_button_mouse_entered() -> void:
	var message = """
	Blue 1
	Slowing tower
	Cost: 300
	Range: 350
	ROF: 500ms
	"""
	show_details(message)

func _on_blue_button_mouse_exited() -> void:
	show_details("")


func _on_g_2_button_mouse_entered() -> void:
	var message = """
	Green 2
	Fast tower
	Targets: 2
	Cost: 400
	Range: 300
	ROF: 25ms
	"""
	show_details(message)


func _on_g_2_button_mouse_exited() -> void:
	show_details("")

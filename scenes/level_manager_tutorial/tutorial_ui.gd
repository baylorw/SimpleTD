class_name TutorialLevelUI extends LevelUI

func enable_button(button: TextureButton):
	if button.disabled:
		button.disabled = false
		button.modulate = Color.WHITE
func disable_button(button: TextureButton):
	if !button.disabled:
		button.disabled = true
		button.modulate = Color.BLACK

func log_clear():
	%DetailsLabel.text += ""
	
func log(message: String):
	%DetailsLabel.text += "\n" + message

func show_affordable_towers():
	for button in get_tree().get_nodes_in_group("build_tower_buttons"):
		var tower_name = button.get_meta("tower_name")
		if !Towers.towers.keys().has(tower_name):
			disable_button(button)
			continue
		var tower : Tower = Towers.towers[tower_name]
		if (tower.cost > CurrentLevel.money):
			print("too expensive: %s for $%s, only have %s" % [tower.name, tower.cost, CurrentLevel.money])
			disable_button(button)
		else:
			enable_button(button)

func show_health():
	%HealthLabel.text = "Health: %s/%s" % [CurrentLevel.base_health, CurrentLevel.base_health_max]

func show_money():
	%MoneyLabel.text = "Money: %s" % [CurrentLevel.money]
	show_affordable_towers()

func show_wave():
	%WaveLabel.text = "Wave: %s/%s" % [CurrentLevel.wave_number, CurrentLevel.wave_number_max]

func show_details(message: String):
	%DetailsLabel.text = message

class_name LevelUI extends CanvasLayer

#--- Allows you to turn off $ changes updating the tower buttons.
#--- Needed for handling initialization race conditions in the the tutorial.
var should_suppress_affordable_towers := false

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
	if should_suppress_affordable_towers:
		return
	for button in get_tree().get_nodes_in_group("build_tower_buttons"):
		var tower_name = button.get_meta("tower_name")
		if !Towers.towers.keys().has(tower_name):
			disable_button(button)
			continue
		var tower : Tower = Towers.towers[tower_name]
		if (tower.cost > CurrentLevel.money):
			#print("too expensive: %s for $%s, only have %s" % [tower.name, tower.cost, CurrentLevel.money])
			disable_button(button)
		else:
			enable_button(button)

func show_health():
	%HealthLabel2.text = "Health: %s/%s" % [CurrentLevel.base_health, CurrentLevel.base_health_max]
	%HealthLabel.text = "%s/%s" % [CurrentLevel.base_health, CurrentLevel.base_health_max]
	if (CurrentLevel.base_health as float / CurrentLevel.base_health_max as float) <= 0.25:
		%LifeIcon.modulate = Color.RED
		%HealthLabel.modulate = Color.RED
	elif (CurrentLevel.base_health as float / CurrentLevel.base_health_max as float) <= 0.50:
		%LifeIcon.modulate = Color.ORANGE
		%HealthLabel.modulate = Color.ORANGE
	
func show_money():
	%MoneyLabel2.text = "Money: %s" % [CurrentLevel.money]
	%MoneyLabel.text = "$ %s" % [CurrentLevel.money]
	show_affordable_towers()

func show_wave():
	%WaveLabel2.text = "Wave: %s/%s" % [CurrentLevel.wave_number, CurrentLevel.wave_number_max]
	%WaveLabel.text = "%s/%s" % [CurrentLevel.wave_number, CurrentLevel.wave_number_max]

func show_details(message: String):
	%DetailsLabel.text = message

func disable_all_buttons():
	#print_debug("Turning off all the buttons")
	for button in get_tree().get_nodes_in_group("buttons"):
		#print_debug("disabling " + button.name)
		button.disabled = true
		if button is TextureButton:
			button.modulate = Color.DIM_GRAY
func enable_all_buttons():
	#print("all buttons are ON")
	for button in get_tree().get_nodes_in_group("buttons"):
		button.disabled = false
	show_affordable_towers()

class_name LevelUI extends CanvasLayer

func show_health():
	%HealthLabel.text = "Health: %s/%s" % [CurrentLevel.base_health, CurrentLevel.base_health_max]

func show_money():
	%MoneyLabel.text = "Money: %s" % [CurrentLevel.money]

func show_wave():
	%WaveLabel.text = "Wave: %s/%s" % [CurrentLevel.wave_number, CurrentLevel.wave_number_max]

class_name TutorialLevelManager extends LevelManager

@onready var tutorial: Node = %Tutorial

func _ready():
	Globals.level_name = "res://levels/tutorial/tutorial.tscn"
	super._ready()
	Events.level_loaded.emit()

func is_a_buildable_position(tile_position : Vector2i) -> bool:
	var answer = super.is_a_buildable_position(tile_position)
	return answer
	
#region Game Events
#####################
##     GAME EVENTS
#####################
#func on_creep_destroyed():
	#super.on_creep_destroyed()
#
#func on_wave_ended():
	#super.on_wave_ended()
#
#func on_creep_reached_base():
	#super.on_creep_reached_base()
#
#func on_win():
	#super.on_win()
#
#func on_lose():
	#super.on_lose()
#endregion

#region UI Button events
###########################################################
# UI Buttons
###########################################################
#func _on_send_wave_button_pressed():
	#if CurrentLevel.level_status != CurrentLevel.LevelStatus.BUILD:
		#print("Can't send then next wave, we're in status=" + str(CurrentLevel.level_status))
		#return
	#%SendWaveButton.disabled = true
	#spawn_creeps()

#func _on_pause_button_pressed() -> void:
	##get_tree().paused = !get_tree().is_paused()
	#Engine.time_scale = 0.0
	#
#func _on_speed_half_button_pressed() -> void:
	#Engine.time_scale = 0.5
#func _on_speed_normal_button_pressed() -> void:
	#Engine.time_scale = 1
#func _on_speed_2_button_pressed() -> void:
	#Engine.time_scale = 2
#func _on_speed_5_button_pressed() -> void:
	#Engine.time_scale = 5
#endregion

#region Tower Info popup events
func _on_sell_button_pressed() -> void:
	CurrentLevel.money += selected_tower.get_sell_value()
	ui.show_money()
	tower_by_map_coord.erase(selected_tower.position_tile)
	selected_tower.queue_free()
	tower_info_popup_panel.hide()

func _on_target_button_pressed() -> void:
	var strategies = selected_tower.allowed_targeting_strategies
	var index = strategies.find(selected_tower.targeting_strategy)
	index += 1
	if index >= strategies.size():
		index = 0
	selected_tower.targeting_strategy = strategies[index]
	%TargetStrategyLabel.text = selected_tower.get_targeting_strategy_name()

func _on_upgrade_button_pressed() -> void:
	super._on_upgrade_button_pressed()
#endregion

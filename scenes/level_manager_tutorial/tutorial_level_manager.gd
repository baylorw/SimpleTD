class_name TutorialLevelManager extends LevelManager

@onready var shade: TextureRect = %Shade
@onready var highlight_arrow: TextureRect = %HighlightArrow


func _ready():
	super._ready()
	
	shade.visible = false

func can_build():
	if CurrentLevel.level_status != CurrentLevel.LevelStatus.BUILD:
		print("can't build, level isn't in build mode")
		return false
	if !is_attempting_tower_placement:
		print("can't build, !is_attempting_tower_placement")
		return false
	if new_tower.cost > CurrentLevel.money:
		#print("can't build, tower is too expensive")
		return false
	if !is_a_buildable_position_global(get_global_mouse_position()):
		return false
	return true
func is_a_buildable_position(tile_position : Vector2i) -> bool:
	#if is_navigable(tile_position):
		#print("that spot is navigable, towers don't go there")
		#return false
	# TODO: Explicitly mark buildable positions (to differentiate from non-nav and also not-buildable)
	if !is_blocked(tile_position):
		return false
	if is_occupied(tile_position):
		return false
	return true


#####################
##     GAME EVENTS
#####################
func on_creep_destroyed():
	super.on_creep_destroyed()

func on_wave_ended():
	super.on_wave_ended()

func on_creep_reached_base():
	super.on_creep_reached_base()

func on_win():
	super.on_win()

func on_lose():
	super.on_lose()


###########################################################
# UI Buttons
###########################################################
#region UI Button events
func _on_quit_button_pressed():
	SceneNavigation.go_to_level_manager()

func _on_restart_button_pressed():
	get_tree().reload_current_scene()

func _on_send_wave_button_pressed():
	if CurrentLevel.level_status != CurrentLevel.LevelStatus.BUILD:
		print("Can't send then next wave, we're in status=" + str(CurrentLevel.level_status))
		return
	%SendWaveButton.disabled = true
	spawn_creeps()

func _on_pause_button_pressed() -> void:
	#get_tree().paused = !get_tree().is_paused()
	Engine.time_scale = 0.0
	
func _on_speed_half_button_pressed() -> void:
	Engine.time_scale = 0.5
func _on_speed_normal_button_pressed() -> void:
	Engine.time_scale = 1
func _on_speed_2_button_pressed() -> void:
	Engine.time_scale = 2
func _on_speed_5_button_pressed() -> void:
	Engine.time_scale = 5
#endregion

#region Tower Info popup events
func _on_sell_button_pressed() -> void:
	var old_money = CurrentLevel.money
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
	if selected_tower.level >= selected_tower.max_level:
		print("It can't level any higher. Max="+str(selected_tower.max_level))
		return
	if CurrentLevel.money < selected_tower.cost_per_level:
		print("You can't afford an upgrade. %s vs %s" % [CurrentLevel.money, selected_tower.cost_per_level])
		return
	selected_tower.increment_level()
	CurrentLevel.money -= selected_tower.cost_per_level
	ui.show_money()
	tower_info_popup_panel.set_info(selected_tower)
#endregion

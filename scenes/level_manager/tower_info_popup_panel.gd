extends PopupPanel

@onready var tower_name_label: Label = %TowerNameLabel
@onready var description_label: Label = %DescriptionLabel
@onready var range_label: Label = %RangeLabel
@onready var damage_label: Label = %DamageLabel
@onready var rof_label: Label = %RoFLabel
@onready var damage_done_label: Label = %DamageDoneLabel
@onready var kills_label: Label = %KillsLabel
@onready var sell_value_label: Label = %SellValueLabel
@onready var upgraded_stats_label: Label = %UpgradedStatsLabel
@onready var upgrade_button: Button = %UpgradeButton


func set_info(tower: Tower):
	tower_name_label.text = "%s lvl %s" % [tower.type, tower.level]
	description_label.text = tower.purpose
	range_label.text = str(tower.current_range_in_pixels)
	damage_label.text = str(tower.current_damage_per_shot)
	rof_label.text = str(tower.shot_delay_in_ms)
	damage_done_label.text = str(tower.damage_done)
	kills_label.text = str(tower.kills)
	sell_value_label.text = str(tower.get_sell_value_at(tower.level))
	upgraded_stats_label.text = "Cost: %s\n%s dmg\n%s range" \
		% [tower.cost_per_level, tower.get_damage_at(tower.level+1), tower.get_range_at(tower.level+1)]
	upgrade_button.disabled = (CurrentLevel.money < tower.cost_per_level)
	

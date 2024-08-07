extends Node

const tower_names := [
	"green_1_tower", "green_2_tower", "green_3_tower",
	"red_1_tower", "red_2_tower", "red_3_tower"
]
var towers := {}

func _ready():
	for name in tower_names:
		var tower = load_tower(name)
		towers[name] = tower
	
func load_tower(name: String):
	var tower_scene_fqn = "res://scenes/towers/%s.tscn" % name
	var tower_data = load(tower_scene_fqn)
	var new_tower = tower_data.instantiate()
	return new_tower
	
var tower_data = {
	"blue1": {
		"damage": 5,
		"rof": 3,
		"range": 350,
		"category": "bullet"
	},
	"green1": {
		"damage": 20,
		"rof": 1,
		"range": 350,
		"category": "bullet"
	},
	"red1": {
		"damage": 100,
		"rof": 0.3,
		"range": 550,
		"category": "rocket"
	}
}

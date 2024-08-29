extends Node

const tower_names := [
	"blue_1_tower",
	"green_1_tower", "green_2_tower", "green_3_tower",
	"red_1_tower", "red_2_tower", "red_3_tower"
]
var towers := {}

func _ready():
	for tower_name in tower_names:
		var tower = load_tower(tower_name)
		towers[tower_name] = tower
	
func load_tower(tower_name: String):
	var tower_scene_fqn = "res://scenes/towers/%s.tscn" % tower_name
	var tower_data = load(tower_scene_fqn)
	var new_tower = tower_data.instantiate()
	#print("loaded "+tower_scene_fqn)
	return new_tower
	
#var tower_data = {
	#"blue1": {
		#"damage": 5,
		#"rof": 3,
		#"range": 350,
		#"category": "bullet"
	#},
	#"green1": {
		#"damage": 20,
		#"rof": 1,
		#"range": 350,
		#"category": "bullet"
	#},
	#"red1": {
		#"damage": 100,
		#"rof": 0.3,
		#"range": 550,
		#"category": "rocket"
	#}
#}

extends Node

const creep_names := [
	#--- Normal
	"weak", "normal", "tough",
	"chicken",
	#"weak_2", "normal_2", "tough_slow_2",
	#"weak_3", "normal_3", "tough_slow_3",
	#--- Fast
	"fast", "fast",
	#"fast_on_straights", "sprint_on_damage", "sprint_near_death",
	#--- Special
	#"disable_tower", "front_shield", "juggernaut", "haste_others", "heal_others", 
	#"loner", "martyr", "regenerate", "shield_others", "spawner",
	#--- Special on death
	#"clown_car", "disable_tower_on_death", "explode", "heal_on_death", "lootbox",
	#--- Steering
	#"drunk", "overshoots",
	#--- Audibles
	#"screamer",
	#--- Fireworks
	#"confetti",
	# unfair, i don't wanna!, cry, laugh, dattebayo
	#--- Unwanted
	#"armor", "flying", "resist_certain_towers", "untargetable_by_certain_towers", 
	"untargetable_at_times"
]
var creep_by_name := {
	"no_op": null
}

func _ready():
	for creep_name in creep_names:
		var resource = load_creep(creep_name)
		if resource:
			creep_by_name[creep_name] = resource
		#else:
			#print("not implemented creep=" + creep_name)
	
func load_creep(creep_name: String) -> Resource:
	#print("want to load creep=" + creep_name)
	#var scene_fqn := "res://scenes/creeps/%s/%s.tscn"
	var scene_fqn := "res://scenes/creeps/%s/%s.tscn" % [creep_name, creep_name]
	print("loading creep=" + scene_fqn)
	var resource : Resource = load(scene_fqn)
	if resource:
		return resource
	else:
		print("creep not found=" + scene_fqn)
		return null

class_name Red2Tower extends Tower

@onready var fire_sound: AudioStreamPlayer2D = %FireSound


func _ready() -> void:
	super._ready()
	purpose = "Fast tower. Random targets."
	
func fire():
	if enemies_in_range.is_empty():
		return
	var enemy_index := randi() % enemies_in_range.size()
	var target = enemies_in_range[enemy_index]
	
	super.fire()
	
	#var bullet : Projectile = load("res://scenes/projectiles/red_2_bullet.tscn").instantiate()
	var bullet := projectile_prototype.duplicate()
	bullet.target = target
	%Shots.add_child(bullet)
	fire_sound.play()
	# TODO: Only give credit when/if it hits
	self.damage_done += current_damage_per_shot

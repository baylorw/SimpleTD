class_name Red3Tower extends Tower

@onready var fire_sound: AudioStreamPlayer2D = %FireSound


func _ready() -> void:
	super._ready()
	purpose = "Slow but powerful."

func fire():
	if enemies_in_range.is_empty():
		return
	#var enemy_index := randi() % enemies_in_range.size()
	#var target = enemies_in_range[enemy_index]
	
	super.fire()
	
	var bullet : Projectile = load("res://scenes/projectiles/red_3_bullet.tscn").instantiate()
	bullet.target = current_target
	bullet.damage = self.current_damage_per_shot
	# TODO: Only give credit when/if it hits
	self.damage_done += current_damage_per_shot
	#bullet.scale = Vector2(2,2)
	%Shots.add_child(bullet)
	fire_sound.play()

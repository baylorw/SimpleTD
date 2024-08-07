class_name Red3Tower extends Tower

@onready var fire_sound: AudioStreamPlayer2D = %FireSound


func _ready() -> void:
	super._ready()
	purpose = "Slow but powerful."

func fire():
	if enemies_in_range.is_empty():
		return
	var enemy_index := randi() % enemies_in_range.size()
	var target = enemies_in_range[enemy_index]
	
	super.fire()
	
	var bullet : Projectile = load("res://scenes/projectiles/red_3_bullet.tscn").instantiate()
	bullet.target = target
	bullet.damage = self.damage_per_shot
	#bullet.scale = Vector2(2,2)
	%Shots.add_child(bullet)
	fire_sound.play()

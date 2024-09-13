class_name Red1Tower extends Tower

@onready var beam: Line2D = %Beam
@onready var fire_sound: AudioStreamPlayer2D = %FireSound
@onready var shot_visibility_timer: Timer = %ShotVisibilityTimer


func _ready() -> void:
	super._ready()
	%Beam.visible = false
	purpose = "Area of Effect."

func fire():
	super.fire()
	
	var enemies : Array[Creep] = []
	var number_of_targets = enemies_in_range.size()
	for i in number_of_targets:
		enemies.append(enemies_in_range[i])
		var new_beam = %Beam.duplicate()
		new_beam.points = [Vector2.ZERO, beam.to_local(enemies_in_range[i].position)]
		new_beam.visible = true
		%Shots.add_child(new_beam)
	shot_visibility_timer.start()
	fire_sound.play()
	
	for enemy in enemies:
		enemy.on_hit(current_damage_per_shot)
		self.damage_done += current_damage_per_shot

func clear_shots():
	for shot in %Shots.get_children():
		shot.queue_free()

func _on_shot_visibility_timer_timeout() -> void:
	clear_shots()

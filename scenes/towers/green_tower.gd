class_name GreenTower extends Tower

@onready var beam: Line2D = %Beam
@onready var fire_sound: AudioStreamPlayer2D = %FireSound
@onready var hit_effects: Node2D = %HitEffects

var max_targets := 1


func _ready() -> void:
	super._ready()
	beam.visible = false
	#randomize_beam_color()
	#print("default_color=" + str(beam.default_color) + " modulate=" + str(beam.modulate))

func randomize_beam_color():
	#--- Start as green then tweak each channel just a little.
	var total_variance := 0.75
	var variance = randf_range(0, total_variance)
	var r = variance
	
	total_variance -= variance
	variance = randf_range(0, total_variance)
	var b = variance

	total_variance -= variance
	variance = total_variance	# get all the leftover variance
	var g = 0.50 + variance
	g = min(g, 1)
	
	var beam_color = Color(r, g, b, 1)
	beam.default_color = beam_color
	#beam.modulate = Color.WHITE

func randomize_beam_color_old():
	#--- Start as green then tweak each channel just a little.
	var r = 0 + randf_range( 0,   0.70)
	var g = 0.75 + randf_range(-0.05, 0.15)
	var b = 0 + randf_range( 0,   0.70)
	#var beam_color = Color(snappedf(r, 0.01), snappedf(g, 0.01), snappedf(b, 0.01), 1)
	var beam_color = Color(r, g, b, 1)
	#beam_color = Color(0,1,0,1)
	#print("desired beam color=" + str(beam_color))
	#beam_color = Color.RED
	#print("beam color=" + str(beam_color))
	beam.default_color = beam_color
	#--- This is needed because SOMETHING is changing this before _ready() and i can't find what.
	beam.modulate = Color.WHITE
	#print("actual  beam color=" + str(beam.default_color))

func fire():
	super.fire()
	
	var points  := [Vector2.ZERO]
	var enemies : Array[Creep] = []
	#print("min(%s, %s)" % [max_targets, enemies_in_range.size()])
	var number_of_targets = min(max_targets, enemies_in_range.size())
	for i in number_of_targets:
		enemies.append(enemies_in_range[i])
		#--- Instead of beams hitting the center, let them bounce around a little to look cooler.
		var x_offset = randf_range(-5, 5)
		var y_offset = randf_range(-5, 5)
		var shoot_point = enemies_in_range[i].position + Vector2(x_offset, y_offset)
		#--- We need to use to_local and i truly don't know why.
		points.append(beam.to_local(shoot_point))
		var particle_system : GPUParticles2D = hit_effects.get_child(i)
		particle_system.position = to_local(shoot_point)
		particle_system.restart()
		particle_system.emitting = true
	beam.points = points
	for enemy in enemies:
		enemy.on_hit(current_damage_per_shot)
		self.damage_done += current_damage_per_shot
	shot_animator.play("fire")
	fire_sound.play()
	

func get_description() -> String:
	return super.get_description()

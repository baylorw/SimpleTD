class_name GreenTower extends Tower

@onready var fire_sound: AudioStreamPlayer2D = %FireSound

var max_targets := 1


func _ready() -> void:
	super._ready()
	randomize_beam_color()
	print("default_color=" + str(beam.default_color) + " modulate=" + str(beam.modulate))

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
	beam.modulate = Color.WHITE

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
	is_ready_to_fire = false
	
	var points  := [Vector2.ZERO]
	var enemies : Array[PathFollower] = []
	#print("min(%s, %s)" % [max_targets, enemies_in_range.size()])
	var number_of_targets = min(max_targets, enemies_in_range.size())
	for i in number_of_targets:
		enemies.append(enemies_in_range[i])
		points.append(beam.to_local(enemies_in_range[i].position))
	beam.points = points
	for enemy in enemies:
		enemy.on_hit(damage_per_shot)
	shot_animator.play("fire")
	fire_sound.play()
	
	var seconds_to_wait : float = shot_delay_in_ms / 1000.0
	await get_tree().create_timer(seconds_to_wait).timeout
	is_ready_to_fire = true

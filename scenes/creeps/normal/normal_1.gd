extends Creep

func _ready() -> void:
	super._ready()
	#spin(randf_range(3,5))
	spin(2)
	#grow(Vector2(0.1,0.1), sprite.scale, 2)
	grow_strobe(Vector2(0.5,0.5), sprite.scale, 1)

class_name Strober extends AnimationPlayer

@export_enum("grow", "spin") var default_animation_name : String = "grow"

func _ready() -> void:
	#current_animation = default_animation_name
	print("current animation=" + current_animation)
	print("playing tne animation now")
	self.play(default_animation_name)

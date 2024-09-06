class_name StrobeSquare extends Sprite2D

@export var default_animation_name : String = "green_grow"

func _ready() -> void:
	set_animation(default_animation_name)

func get_animation() -> String:
	return %AnimationPlayer.current_animation
	
func set_animation(animation_name: String):
	%AnimationPlayer.current_animation = animation_name

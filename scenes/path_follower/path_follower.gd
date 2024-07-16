class_name PathFollower extends CharacterBody2D

# TODO: The export values don't seem to do anything. Investigate.
#@export var acceleration := 9000.0
#@export var decceleration := 5000.0
@export var max_speed := 300.0
@export var endpoint_slow_radius := 25.0
@export var midpoint_slow_radius := 0.0
# TODO: have one for midpoints and endpoint
@export var close_enough := 10.0

var _texture : Texture2D
@export var texture : Texture2D :
	set(value):
		_texture = value
		if (null != sprite):
			sprite.texture = _texture
	get:
		return _texture

@onready var sprite : Sprite2D = $Sprite2D

var current_slow_radius := midpoint_slow_radius

var path : Array[Vector2]
var desired_position : Vector2
var is_seeking := false


func _ready():
	sprite.texture = _texture

func get_size() -> Vector2 :
	return $Sprite2D.texture.get_size()
	
func follow(new_path : Array[Vector2]):
	self.path = new_path
	
	#--- Not sure why this happens but it happens at random if you try to set a new path
	#---	while it's already following one.
	if null == new_path or path.is_empty():
		is_seeking = false
		return
		
	# TODO: Reverse the path so can pop from back, which is a lot faster.
	desired_position = path.pop_front()
	is_seeking = true

func _physics_process(delta):
	_physics_process_steering(delta)
	
func _physics_process_simple(_delta):
	if !is_seeking:
		return

	if global_position.distance_to(desired_position) < close_enough:
		if path.is_empty():
			is_seeking = false
			return
		else:
			desired_position = path.pop_front()
			look_at(desired_position)

	velocity = global_position.direction_to(desired_position) * max_speed
	#if position.distance_to(desired_position) > 10:
	move_and_slide()

func _physics_process_steering(_delta):
	if !is_seeking:
		return

	if global_position.distance_to(desired_position) < close_enough:
		if path.is_empty():
			is_seeking = false
		else:
			desired_position = path.pop_front()
			look_at(desired_position)
			#--- Is this the last segment?
			if path.is_empty():
				current_slow_radius = endpoint_slow_radius
			else:
				current_slow_radius = midpoint_slow_radius

	if !is_seeking:
		return
	
	#print("arrive_to v=" + str(velocity) + " max=" + str(max_speed))
	velocity = Steering.arrive_to(
		velocity,
		global_position,
		desired_position,
		max_speed,
		current_slow_radius
	)
	move_and_slide()

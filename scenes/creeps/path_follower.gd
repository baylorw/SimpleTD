class_name PathFollower extends CharacterBody2D

#--- Damage done to the player's base.
signal destroyed

# TODO: The export values don't seem to do anything. Investigate.
#@export var acceleration := 9000.0
#@export var decceleration := 5000.0
@export var max_speed := 75.0
@export var endpoint_slow_radius := 25.0
@export var midpoint_slow_radius := 0.0
# TODO: have one for midpoints and endpoint
@export var close_enough := 10.0

@export var max_health := 100
@export var kill_value := 10

# Don't initialize here from export variables, they won't be initialized when this is set.
var health : int
var speed  : float

#var _texture : Texture2D
#@export var texture : Texture2D :
	#set(value):
		#_texture = value
		#if (null != sprite):
			#sprite.texture = _texture
	#get:
		#return _texture

@onready var sprite : Sprite2D = $Sprite2D
@onready var health_bar : TextureProgressBar = %HealthBar
@onready var effects_polling_timer: Timer = %EffectsPollingTimer
@onready var status_icon_container: HBoxContainer = %StatusIconContainer

var current_slow_radius := midpoint_slow_radius

var path : Array[Vector2]
var desired_position : Vector2
var is_seeking := false

## EFFECTS
const tick_length_in_ms := 100
var slow_ticks := 0
var stun_ticks := 0


func _ready():
	#--- Set here because setting in declaration doesn't work when setting from export variables.
	health = max_health
	speed  = max_speed
	
	#sprite.texture = _texture
	health = max_health
	health_bar.max_value = health
	health_bar.value = health
	#--- HP bar doesn't match object's position, rotation, etc.
	#health_bar.top_level = true
	
	for icon in status_icon_container.get_children():
		icon.visible = false
	
	#--- The IDE wiring doesn't work for duplicated objects. The event calls the original object instead.
	effects_polling_timer.timeout.connect(_on_effects_polling_timer_timeout)
	#--- Have to do this even though it's set in the IDE because Godot can suck my balls. 
	effects_polling_timer.autostart = true

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
	#print("_physics_process slow_ticks="+str(self.slow_ticks) + " for name=" + name)
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
		speed,
		current_slow_radius
	)
	move_and_slide()

func on_destroy():
	#--- Give the player money
	CurrentLevel.money += kill_value
	print("Creep %s died, money increasing %s to %s" % [name, kill_value, CurrentLevel.money])

	%Sprite2D.queue_free()
	%CollisionShape2D.queue_free()

	%AudioStreamPlayer2D.play()
	await %AudioStreamPlayer2D.finished
	
	# TODO: Play an explosion animation
	
	# TODO: Why do we do this? Sound effect maybe?
	#await get_tree().create_timer(0.2).timeout
	self.queue_free()
	#print("i'm a destroyed creep and i'm free!")
	destroyed.emit()

## Right now this assumes there's only one level of slow, 50%
func slow(my_tick_count: int):
	self.slow_ticks = my_tick_count
	modify_speed()

func stun(tick_count: int):
	stun_ticks = tick_count
	modify_speed()

func on_hit(damage : int):
	#impact()
	#--- Deal with race conditions
	if health <= 0:
		return
	health -= damage
	health_bar.value = health
	if health_bar.ratio < 0.5:
		health_bar.tint_progress = Color("red")
	#print("creep took %s damage, hp=%s" % [damage, health])
	if health <= 0:
		on_destroy()

## Show on the creep where he touched you.
#func impact():
	#var x_pos = (randi() % 40) - 20
	#var y_pos = (randi() % 40) - 20
	#var impact_location = Vector2(x_pos, y_pos)
	#var new_impact = gun_impact.instantiate()
	#new_impact.position = impact_location
	#impact_area.add_child(new_impact)

func _on_effects_polling_timer_timeout() -> void:

	# damage ticks
	
	#print("poll time="+ str(Time.get_ticks_msec()) + " slow_ticks=" + str(slow_ticks) + " creep="+name)
	
	# status ticks
	if slow_ticks > 0:
		slow_ticks -= 1
		if 0 == slow_ticks:
			modify_speed()
	if stun_ticks > 0:
		stun_ticks -= 1
		if 0 == stun_ticks:
			modify_speed()

func modify_speed():
	if stun_ticks > 0:
		print("sturn means turning off the slow icon")
		%StunIcon.visible = true
		%SlowIcon.visible = false
		speed = 0.0
	elif slow_ticks > 0:
		print("turning on the slow icon")
		%StunIcon.visible = false
		%SlowIcon.visible = true
		speed = 0.50 * max_speed
	else:
		print("turning off the slow icon")
		%StunIcon.visible = false
		%SlowIcon.visible = false
		speed = max_speed

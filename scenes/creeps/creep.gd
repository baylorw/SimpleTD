class_name Creep extends CharacterBody2D

#--- Damage done to the player's base.
signal destroyed

@export_category("Animation")
## Should this creep fade in and/or out?
@export_enum("None", "Once", "Loop") var fade_mode := "None"
@export_range(0, 1, 0.05) var fade_start  : float = 0 
@export_range(0, 1, 0.05) var fade_end    : float = 1
@export                   var fade_time_s : float = 1
## Should this creep grow big and/or small?
@export_enum("None", "Once", "Loop") var grow_mode := "None"
@export_range(0, 2, 0.05) var grow_start  : float = 0
@export_range(0, 2, 0.05) var grow_end    : float = 0.8
@export                   var grow_time_s : float = 1
## Should this creep grow big and/or small?
@export_enum("None", "Once", "Loop") var rotate_mode := "None"
@export_range(-360, 360, 1) var rotate_start  : float = 0
@export_range(-360, 360, 1) var rotate_end    : float = 360
@export                     var rotate_time_s : float = 1
## Should this creep spin?
@export_enum("None", "Once", "Loop") var spin_mode := "None"
@export var spin_speed : float = 1

@export_category("Steering")
# TODO: The export values don't seem to do anything. Investigate.
#@export var acceleration := 9000.0
#@export var decceleration := 5000.0
@export var max_speed            := 75.0
@export var endpoint_slow_radius := 25.0
@export var midpoint_slow_radius := 0.0
# TODO: have one for midpoints and endpoint
@export var close_enough := 10.0
var current_slow_radius := midpoint_slow_radius

@export_category("Stats")
@export var base_max_health   := 100
@export var base_kill_value   :=  10
## How much (percentage) the health goes up per level. 
## Formula: max_health = base * (1+multiplier)^(level-1)
@export var health_multiplier := 0.22
## How much money the creep's value goes up each level. 
@export var value_increase    := 1
# Don't initialize these variable from export variables here, use _ready(). They won't be initialized when this is set.
var level      : int = 1
var max_health : int
var health     : int
var kill_value : int
var speed      : float

@onready var sprite : AnimatedSprite2D = $Sprite2D
@onready var health_bar : TextureProgressBar = %HealthBar
@onready var effects_polling_timer: Timer = %EffectsPollingTimer
@onready var status_icon_container: HBoxContainer = %StatusIconContainer
@onready var slow_icon: TextureRect = %SlowIcon
@onready var stun_icon: TextureRect = %StunIcon
@onready var poison_icon: TextureRect = %PoisonIcon
var death_animation: AnimatedSprite2D

var should_show_distance := false
var distance_label: Label

var expected_health_bar_position : Vector2
var expected_status_position : Vector2

var path : Array[Vector2]
var desired_position : Vector2
var is_seeking := false
var i_am := true  # therefore exists

## EFFECTS
const tick_length_in_ms := 100
var slow_ticks := 0
var stun_ticks := 0


func _ready():
	#--- Set here because setting in declaration doesn't work when setting from export variables.
	set_level(level)
	speed  = max_speed
	
	#print("hp position=" + str(health_bar.position) + " and status=" + str(status_icon_container.position))
	expected_health_bar_position = health_bar.position
	expected_status_position = status_icon_container.position
	
	health_bar.max_value = health
	health_bar.value = health
	health_bar.visible = false
	#--- HP bar doesn't match object's position, rotation, etc.
	# NOTE: If you turn this on you have to move the HP bar manually :(
	health_bar.top_level = true
	status_icon_container.top_level = true
	
	for icon in status_icon_container.get_children():
		icon.visible = false
	
	#--- The IDE wiring doesn't work for duplicated objects. The event calls the original object instead.
	effects_polling_timer.timeout.connect(_on_effects_polling_timer_timeout)
	#--- Have to do this even though it's set in the IDE because Godot can suck my balls. 
	effects_polling_timer.autostart = true
	
	setup_procedural_animation()
	if is_instance_valid(%DeathAnimation):
		death_animation = %DeathAnimation
		death_animation.visible = false
		
	distance_label = Label.new()
	distance_label.position = status_icon_container.position - Vector2(0,23)
	if should_show_distance:
		add_child(distance_label)
	else:
		distance_label.visible = false

func set_level(new_level: int):
	self.level = new_level
	kill_value = base_kill_value + ((level-1) * value_increase)
	
	#health = base * =(1+multiplier)^(level-1)
	var level_adjustment = pow((1+health_multiplier), (level-1))
	max_health = floor(base_max_health * level_adjustment)
	health = max_health
	#print("level=%s, adjustment=%s, hp=%s, value=%s" % [level, level_adjustment, health, kill_value])

func setup_procedural_animation():
	match fade_mode:
		"Once":
			fade(fade_start, fade_end, fade_time_s, false)
		"Loop":
			fade(fade_start, fade_end, fade_time_s, true)
	match grow_mode:
		"Once":
			grow(Vector2(grow_start, grow_start), Vector2(grow_end, grow_end), grow_time_s, false)
		"Loop":
			grow(Vector2(grow_start, grow_start), Vector2(grow_end, grow_end), grow_time_s, true)
	match rotate_mode:
		"Once":
			rotate_anim(rotate_start, rotate_end, rotate_time_s, false)
		"Loop":
			rotate_anim(rotate_start, rotate_end, rotate_time_s, true)
	match spin_mode:
		"Once":
			spin(spin_speed, false)
		"Loop":
			spin(spin_speed, true)

func get_size() -> Vector2 :
	return $Sprite2D.texture.get_size()

func get_sprite() -> AnimatedSprite2D:
	# Need this to access value if the object isn't in the screengraph.
	return $Sprite2D
	
func follow(new_path : Array[Vector2]):
	self.path = new_path.duplicate()
	
	#--- Not sure why this happens but it happens at random if you try to set a new path
	#---	while it's already following one.
	if null == new_path or path.is_empty():
		is_seeking = false
		return
		
	# TODO: Reverse the path so can pop from back, which is a lot faster.
	desired_position = path.pop_front()
	is_seeking = true

func _physics_process(delta):
	#if !is_instance_valid(status_icon_container):
		#print("THIS SHOULD NEVER HAPPEN!!! status icons are dead but not the creep")
		#return
	
	health_bar.position = global_position + expected_health_bar_position
	status_icon_container.position = global_position + expected_status_position
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
			distance_label.text = str(path.size())
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
	#--- Stop calling the _physics_process() method.
	set_physics_process(false)

	#print("i am destroyed. " + name)
	i_am = false
	
	#--- Give the player money
	CurrentLevel.money += kill_value
	#print("Creep %s died, money increasing %s to %s" % [name, kill_value, CurrentLevel.money])

	#--- Hide everything but don't destroy the enemy until its death scream is done.
	%CollisionShape2D.queue_free()
	%Sprite2D.queue_free()
	%StatusIconContainer.queue_free()

	#--- Death sound and spectacle
	if %AudioStreamPlayer2D:
		%AudioStreamPlayer2D.play()
	if death_animation:
		death_animation.visible = true
		death_animation.play()
	if %AudioStreamPlayer2D:
		await %AudioStreamPlayer2D.finished
	if death_animation:
		# TODO: AnimatedSprite2D signal doesn't work. Figure out something else.
		#await death_animation.animation_finished
		await get_tree().create_timer(1.5).timeout
		#death_animation.queue_free()
	
	self.queue_free()
	destroyed.emit()

## Right now this assumes there's only one level of slow, 50%
func slow(my_tick_count: int):
	self.slow_ticks = my_tick_count
	modify_speed()
	self.self_modulate = Color.CYAN

func stun(tick_count: int):
	stun_ticks = tick_count
	modify_speed()

func on_hit(damage : int):
	# TODO: Show getting hit effects. Do i do that or the bullet object?
	#impact()
	
	health_bar.visible = true
	
	#--- Deal with race conditions, of which there have been many.
	if health <= 0:
		return
	health -= damage
	health_bar.value = health
	if health_bar.ratio < 0.5:
		health_bar.tint_progress = Color("red")
	#print("creep took %s damage, hp=%s" % [damage, health])
	if health <= 0:
		on_destroy()

## Show me on the creep where he touched you.
# TODO: Implement impact animations
#func impact():
	#var x_pos = (randi() % 40) - 20
	#var y_pos = (randi() % 40) - 20
	#var impact_location = Vector2(x_pos, y_pos)
	#var new_impact = gun_impact.instantiate()
	#new_impact.position = impact_location
	#impact_area.add_child(new_impact)

func _on_effects_polling_timer_timeout() -> void:
	# damage ticks
	# TODO: Take damage from DoT
	
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
	#--- Deal with the ubiquitous race conditions.
	if !i_am:
		return
		
	if stun_ticks > 0:
		#print("stun means turning off the slow icon")
		%StunIcon.visible = true
		%SlowIcon.visible = false
		self.self_modulate = Color.BLUE
		speed = 0.0
	elif slow_ticks > 0:
		#print("turning on the slow icon")
		%StunIcon.visible = false
		%SlowIcon.visible = true
		self_modulate = Color.CYAN
		speed = 0.50 * max_speed
	else:
		#print("turning off the slow icon")
		%StunIcon.visible = false
		%SlowIcon.visible = false
		self.self_modulate = Color.WHITE
		speed = max_speed

###########################################################
# Animations
###########################################################
func fade(start: float, end: float, time_length_s: float, should_loop: bool):
	var tween = sprite.create_tween()
	if should_loop:
		tween.set_loops()
	tween.tween_property(sprite, "modulate:a", end, time_length_s).from(start)
	if should_loop:
		tween.tween_property(sprite, "modulate:a", start, time_length_s).from(end)

func grow(start: Vector2, end: Vector2, time_length_s: float, should_loop: bool):
	var tween = sprite.create_tween()
	#tween.set_trans(Tween.TRANS_BOUNCE)
	#tween.set_ease(Tween.EASE_IN_OUT)
	if should_loop:
		tween.set_loops()
	tween.tween_property(sprite, "scale", end, time_length_s).from(start)
	if should_loop:
		tween.tween_property(sprite, "scale", start, time_length_s).from(end)

func rotate_anim(start: float, end: float, time_length_s: float, should_loop: bool):
	var tween = sprite.create_tween()
	if should_loop:
		tween.set_loops()
	tween.tween_property(sprite, "rotation_degrees", end, time_length_s).from(start)
	if should_loop:
		tween.tween_property(sprite, "rotation_degrees", start, time_length_s).from(end)

#func grow_strobe(min: Vector2, max: Vector2, time_length_s: float):
	#var tween = create_tween().set_loops()
	#tween.tween_property(sprite, "scale", max, time_length_s/2).from(min)
	#tween.tween_property(sprite, "scale", min, time_length_s/2).from_current()

func spin(new_spin_speed: float, should_loop: bool):
	#var degrees_360 = TAU    # i hate this so much
	var tween = sprite.create_tween()
	if should_loop:
		tween.set_loops()
	#tween.tween_property(sprite, "rotation", degrees_360, spin_speed).from(0)
	tween.tween_property(sprite, "rotation_degrees", 360, new_spin_speed).from(0)

class_name Tower extends Node2D

@onready var shot_animator: AnimationPlayer = %FireAnimationPlayer
@onready var range_area: Area2D = %RangeArea
@onready var range_collider: CollisionShape2D = %RangeCollider
@onready var range_sprite: Sprite2D = %RangeSprite
@onready var shot_timer: Timer = $ShotTimer

@export var cost : int
@export var damage_per_shot : int
@export var shot_delay_in_ms : int
@export var range_in_pixels : int
#@export var projectile_prototype : Projectile
@export var projectile_resource : PackedScene
@export var purpose : String
#@export var range : int:
	#get:
		#return range
	#set(value):
		#set_range(value)

var enemies_in_range := []
var is_ready_to_fire := true
var in_attack_mode := false
var projectile_prototype : Projectile


func _ready() -> void:
	range_sprite.visible = false
	set_range(range_in_pixels)
	shot_timer.wait_time = (shot_delay_in_ms / 1000.0)
	shot_timer.timeout.connect(on_shot_timer_timeout)
	
	if projectile_resource:
		print("instantiating the prototype bullet")
		projectile_prototype = projectile_resource.instantiate()
	else:
		print("no projectile_resource :(")

func on_shot_timer_timeout():
	is_ready_to_fire = true

func _physics_process(_delta: float) -> void:
	if !enemies_in_range.is_empty() and is_ready_to_fire:
		fire()

func fire():
	is_ready_to_fire = false
	shot_timer.start()

func get_description() -> String:
	var description = """
		%s
		%s
		Cost: %s
		Damage: %s
		RoF: %s
		Range: %s
		""" % [name, purpose, cost, damage_per_shot, shot_delay_in_ms, range_in_pixels]
	return description

func set_range(new_range : int):
	range_in_pixels = new_range
	range_collider.shape.radius = (new_range * 0.5)
	#--- What the fuck is wrong with Godot? You can't set the size directly? WTF?
	var fucking_scale_factor = new_range / (range_sprite.texture.get_width() as float)
	#print("fucking sprite scaling factor=" + str(fucking_scale_factor))
	range_sprite.scale = Vector2(fucking_scale_factor, fucking_scale_factor)
	#print("range_in_pixels=%s, collider radius=%s, scale=%s" % [range_in_pixels, range_collider.shape.radius, range_sprite.scale])

func set_range_color(color: Color):
	if range_sprite.modulate != color:
		range_sprite.modulate = color
func set_tower_color(color: Color):
	if %TowerSprite.modulate != color:
		%TowerSprite.modulate = color

func show_range(should_show : bool):
	range_sprite.visible = should_show
func toggle_show_range():
	show_range(!range_sprite.visible)

func _on_range_body_entered(body: Node2D) -> void:
	enemies_in_range.append(body)
	in_attack_mode = true

func _on_range_body_exited(body: Node2D) -> void:
	enemies_in_range.erase(body)
	in_attack_mode = !enemies_in_range.is_empty()

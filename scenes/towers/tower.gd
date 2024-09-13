class_name Tower extends Node2D

enum TargetingStrategy {Closest_To_Goal, Most_Health, Least_Health, Fastest, Nearest, Random}

@onready var shot_animator: AnimationPlayer = %FireAnimationPlayer
@onready var range_area: Area2D = %RangeArea
@onready var range_collider: CollisionShape2D = %RangeCollider
@onready var range_sprite: Sprite2D = %RangeSprite
@onready var shot_timer: Timer = $ShotTimer

## Name of the tower (e.g., Green 1). Can't use name at runtime because new instances get new names.
@export var type : String 
@export var cost : int
@export var cost_per_level : int
var current_damage_per_shot : int
@export var base_damage_per_shot : int
@export var damage_per_level : int
@export var shot_delay_in_ms : int
@export var base_range_in_pixels : int
var current_range_in_pixels : int
@export var range_per_level : int
# ERROR: Trying to assign an array of type Array to a variable of type Array[int]
#@export var allowed_targeting_strategies : Array[TargetingStrategy] = TargetingStrategy.keys()
@export var allowed_targeting_strategies : Array[TargetingStrategy]
@export var projectile_resource : PackedScene
@export var purpose : String
#@export var range : int:
	#get:
		#return range
	#set(value):
		#set_range(value)

var should_stay_on_target := true
var enemies_in_range := []
var is_ready_to_fire := true
var in_attack_mode := false
var projectile_prototype : Projectile

var level := 1 : 
	set = set_level
var max_level := 10

var position_tile : Vector2i

var damage_done := 0
var kills := 0


func _ready() -> void:
	range_sprite.visible = false
	set_level(1)
	#set_range(range_in_pixels)
	shot_timer.wait_time = (shot_delay_in_ms / 1000.0)
	shot_timer.timeout.connect(on_shot_timer_timeout)
	
	if projectile_resource:
		print("instantiating the prototype bullet")
		projectile_prototype = projectile_resource.instantiate()
	#else:
		#print("no projectile_resource :(")

func increment_level():
	level += 1
func set_level(value: int):
	print("set_level to " + str(value))
	level = value
	print("so now the fucking level is " + str(level))
	current_damage_per_shot = get_damage_at(level)
	current_range_in_pixels = get_range_at(level)
	set_range(current_range_in_pixels)
	print("new values level=%s, dmg=%s, range=%s" % [level, current_damage_per_shot, current_range_in_pixels])

func get_damage_at(target_level: int):
	var value = base_damage_per_shot + (damage_per_level * (target_level-1))
	return value
	
func get_range_at(target_level: int):
	var level_bonus = range_per_level * (target_level-1)
	var value = base_range_in_pixels + level_bonus
	print("base=%s, increase per level=%s, level=%s, increase=%s" % 
		[base_range_in_pixels, range_per_level, target_level, level_bonus])
	return value
	
func get_sell_value():
	return get_sell_value_at(level)
func get_sell_value_at(target_level: int) -> int:
	var value = cost + (cost_per_level * (target_level-1))
	return floor(0.75 * value)

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
		""" % [type, purpose, cost, base_damage_per_shot, shot_delay_in_ms, base_range_in_pixels]
	return description

func set_range(new_range : int):
	current_range_in_pixels = new_range
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

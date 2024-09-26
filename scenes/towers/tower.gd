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
@export var allowed_targeting_strategies : Array[TargetingStrategy] = \
	[
		TargetingStrategy.Closest_To_Goal,
		TargetingStrategy.Most_Health,
		TargetingStrategy.Least_Health,
		TargetingStrategy.Fastest,
		TargetingStrategy.Nearest,
		TargetingStrategy.Random
	]
@export var targeting_strategy : TargetingStrategy = TargetingStrategy.Closest_To_Goal
@export var should_stay_on_target := true
@export var projectile_resource : PackedScene
@export var purpose : String
#@export var range : int:
	#get:
		#return range
	#set(value):
		#set_range(value)

var current_target : Creep
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
	level = value
	current_damage_per_shot = get_damage_at(level)
	current_range_in_pixels = get_range_at(level)
	set_range(current_range_in_pixels)
	#print("new values level=%s, dmg=%s, range=%s" % [level, current_damage_per_shot, current_range_in_pixels])

func get_damage_at(target_level: int):
	var value = base_damage_per_shot + (damage_per_level * (target_level-1))
	return value
	
func get_range_at(target_level: int):
	var level_bonus = range_per_level * (target_level-1)
	var value = base_range_in_pixels + level_bonus
	#print("base=%s, increase per level=%s, level=%s, increase=%s" % 
		#[base_range_in_pixels, range_per_level, target_level, level_bonus])
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
	current_target = select_target()

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

## Can't used this method because you can't pass an invalid target to a method. :(
func is_valid_target(target: Creep) -> bool:
	if !is_instance_valid(target):
		return false
	if !target.i_am:
		return false
	return true
	
func sort_enemies():
	match targeting_strategy:
		TargetingStrategy.Closest_To_Goal:
			enemies_in_range.sort_custom(func(a:Creep, b:Creep): return a.path.size() < b.path.size())
		TargetingStrategy.Most_Health:
			enemies_in_range.sort_custom(func(a:Creep, b:Creep): return a.health > b.health)
		TargetingStrategy.Least_Health:
			enemies_in_range.sort_custom(func(a:Creep, b:Creep): return a.health < b.health)
		TargetingStrategy.Fastest:
			enemies_in_range.sort_custom(func(a:Creep, b:Creep): return a.speed > b.speed)
		TargetingStrategy.Nearest:
			enemies_in_range.sort_custom(
				func(a:Creep, b:Creep): 
					return position.distance_to(a.position) < position.distance_to(b.position)
			)
		TargetingStrategy.Random:
			return enemies_in_range
	return enemies_in_range
	
func get_targeting_strategy_name() -> String:
	var strategy_name : String = TargetingStrategy.keys()[targeting_strategy]
	return strategy_name

func select_target() -> Creep:
	#print("in range=" + str(enemies_in_range.size()))
	if 0 == enemies_in_range.size():
		return null
	if 1 == enemies_in_range.size():
		return enemies_in_range[0]
	if should_stay_on_target and is_instance_valid(current_target) and current_target.i_am:
		return current_target
	if targeting_strategy == TargetingStrategy.Random:
		var enemy_index := randi() % enemies_in_range.size()
		return enemies_in_range[enemy_index]
	var targets = sort_enemies()
	#if targets.size() > 5:
		#print("lots of targets=" + str(targets.size()))
		#for t in targets:
			#print("%s path steps left=%s" % [t, t.path.size()])
		#print("my choice is %s with %s left" % [targets[0], targets[0].path.size()] )
	current_target = targets[0]
	return targets[0]
	
func _on_range_body_entered(body: Node2D) -> void:
	enemies_in_range.append(body)
	in_attack_mode = true

func _on_range_body_exited(body: Node2D) -> void:
	enemies_in_range.erase(body)
	in_attack_mode = !enemies_in_range.is_empty()

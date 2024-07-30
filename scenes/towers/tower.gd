class_name Tower extends Node2D

@onready var beam: Line2D = %Beam
@onready var shot_animator: AnimationPlayer = %FireAnimationPlayer
@onready var range_area: Area2D = %RangeArea
@onready var range_collider: CollisionShape2D = %RangeCollider
@onready var range_sprite: Sprite2D = %RangeSprite

@export var cost : int
@export var damage_per_shot : int
@export var shot_delay_in_ms : int
@export var range_in_pixels : int
#@export var range : int:
	#get:
		#return range
	#set(value):
		#set_range(value)

var enemies_in_range := []
var is_ready_to_fire := true
var in_attack_mode := false


func _ready() -> void:
	range_sprite.visible = false
	beam.visible = false
	set_range(range_in_pixels)

func _physics_process(_delta: float) -> void:
	if !enemies_in_range.is_empty() and is_ready_to_fire:
		fire()

func fire_at_mouse():
	beam.points = [Vector2.ZERO, beam.to_local(get_global_mouse_position())]
	shot_animator.play("fire")

func fire():
	is_ready_to_fire = false
	
	var points  := [Vector2.ZERO]
	var enemies : Array[PathFollower] = []
	var number_of_targets = min(3, enemies_in_range.size())
	for i in number_of_targets:
		enemies.append(enemies_in_range[i])
		points.append(beam.to_local(enemies_in_range[i].position))
	beam.points = points
	for enemy in enemies:
		enemy.on_hit(damage_per_shot)
	shot_animator.play("fire")
	%FireSound.play()
	
	var seconds_to_wait : float = shot_delay_in_ms / 1000.0
	#print("waiting to fire=" + str(seconds_to_wait))
	#if Engine.time_scale > 0:
		#print("time scale is non-0")
		#seconds_to_wait /= Engine.time_scale
	#print("now waiting to fire=" + str(seconds_to_wait))
	await get_tree().create_timer(seconds_to_wait).timeout
	is_ready_to_fire = true

func print_variables():
	print("the scene objects. beam="+str(%Beam)+" anim="+str(%FireAnimationPlayer)+" range_area="+str(%RangeArea)+" range_collider="+str(%RangeCollider)+" range_sprite="+str(%RangeSprite))
	print("the onready objects. beam="+str(beam)+" anim="+str(shot_animator)+" range_area="+str(range_area)+" range_collider="+str(range_collider)+" range_sprite="+str(range_sprite))

func set_range(new_range : int):
	range_in_pixels = new_range
	range_collider.shape.radius = (new_range * 0.5)
	#--- What the fuck is wrong with Godot? You can't set the size directly? WTF?
	var fucking_scale_factor = new_range / (range_sprite.texture.get_width() as float)
	#print("fucking sprite scaling factor=" + str(fucking_scale_factor))
	range_sprite.scale = Vector2(fucking_scale_factor, fucking_scale_factor)

func set_range_color(color: Color):
	if range_sprite.modulate != color:
		range_sprite.modulate = color

func show_range(should_show : bool):
	range_sprite.visible = should_show
func toggle_show_range():
	show_range(!range_sprite.visible)

func _on_range_body_entered(body: Node2D) -> void:
	enemies_in_range.append(body)
	in_attack_mode = true

func _on_range_body_exited(body: Node2D) -> void:
	#print("body left=" + str(body))
	#--- How annoying that we have to do this.
	#if body is TileMapLayer:
		#return
	enemies_in_range.erase(body)
	in_attack_mode = !enemies_in_range.is_empty()

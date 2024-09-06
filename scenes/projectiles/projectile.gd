class_name Projectile extends CharacterBody2D

@export var damage := 0
@export var speed  := 750
# TODO: Maybe put the explosion/effect to play on hit here
# TODO: Maybe put a sound to play here

#--- Is this bullet still alive or did it explode?
var is_alive := true
var target : Node2D

func _ready() -> void:
	pass # Replace with function body.

func _physics_process(_delta: float) -> void:
	if is_instance_valid(target) and target.i_am:
			move_by_steering()
			#move_by_position()
	else:
		#--- Target is gone, just keep going straight.
		move_and_slide()

func move_by_position():
	position = velocity.move_toward(target.global_position, speed)

func move_by_steering():
	#--- Yes, i know we just checked it but starting in 4.3 things started disappearing 
	#---	between lines.
	if !target:
		#print("target stopped existing somehow")
		#print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		#print("velocity=" + str(self.velocity))
		move_and_slide()
		return
	#if !is_instance_valid(target):
		#print("target isn't valid")
	self.velocity = Steering.follow(
		self.velocity,
		self.global_position,
		target.global_position,
		speed
	)
	move_and_slide()
	#var collision : KinematicCollision2D = move_and_collide(velocity)
	#var body := collision.get_collider()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	self.queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if !is_alive:
		return
	
	#--- Turn this object off but don't remove it from the scene tree yet.
	is_alive = false
	#self.process_mode = Node.PROCESS_MODE_DISABLED
	set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	$Sprite2D.visible = false
	
	body.on_hit(damage)
	impact()

## Show me on the creep where he touched you.
func impact():
	# Can play an animated sprite or particle effect.
	# Can play a sound.
	# TODO: Is this needed?
	#--- Wait a little for impact animations and sounds to finish.
	await get_tree().create_timer(0.2).timeout
	self.queue_free()
	
	#var x_pos = (randi() % 40) - 20
	#var y_pos = (randi() % 40) - 20
	#var impact_location = Vector2(x_pos, y_pos)
	#var new_impact = gun_impact.instantiate()
	#new_impact.position = impact_location
	#impact_area.add_child(new_impact)

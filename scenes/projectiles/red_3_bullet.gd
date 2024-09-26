class_name Red3Bullet extends Projectile

var explosion_resource : Resource

func _ready():
	explosion_resource = preload("res://effects/explosion.tscn")
	pass
	
func impact():
	var explosion = explosion_resource.instantiate()
	var x_pos = (randi() % 40) - 20
	var y_pos = (randi() % 40) - 20
	var impact_location = self.position + Vector2(x_pos, y_pos)
	explosion.position = impact_location
	#--- Add to scene tree as sibling to the bullet or the particles won't show (not sure why).
	get_parent().add_child(explosion)
	explosion.play()
	self.queue_free()
	

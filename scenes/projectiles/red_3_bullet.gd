class_name Red3Bullet extends Projectile

func impact():
	# Can play an animated sprite or particle effect.
	# Can play a sound.
	#--- Wait a little for impact animations and sounds to finish.
	await get_tree().create_timer(0.2).timeout
	self.queue_free()
	
	#var x_pos = (randi() % 40) - 20
	#var y_pos = (randi() % 40) - 20
	#var impact_location = Vector2(x_pos, y_pos)
	#var new_impact = gun_impact.instantiate()
	#new_impact.position = impact_location
	#impact_area.add_child(new_impact)

extends Node

const DEFAULT_MASS := 5.0
const DEFAULT_MAX_SPEED := 400.0
const DEFAULT_SLOW_RADIUS := 200.0

#static func arrive_to(
func arrive_to(
	velocity: Vector2,
	global_position: Vector2,
	target_position: Vector2,
	max_speed := DEFAULT_MAX_SPEED,
	slow_radius := DEFAULT_SLOW_RADIUS,
	mass := DEFAULT_MASS
) -> Vector2:
	var distance_to_target := global_position.distance_to(target_position)
	var desired_velocity := (target_position - global_position).normalized() * max_speed
	if distance_to_target < slow_radius:
		# TODO: Use decelleration here, not a hard coded number
		desired_velocity *= ((distance_to_target / slow_radius) * 0.75) + 0.02
	var steering := (desired_velocity - velocity) / mass
	return velocity + steering

#static func follow(
func follow(
	velocity: Vector2,
	global_position: Vector2,
	target_position: Vector2,
	max_speed := DEFAULT_MAX_SPEED,
	mass := DEFAULT_MASS
) -> Vector2:
	var desired_velocity := (target_position - global_position).normalized() * max_speed
	var steering := (desired_velocity - velocity) / mass
	return velocity + steering

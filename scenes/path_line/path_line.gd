class_name PathLine extends Line2D

var active_texture : Texture = load("res://scenes/path_line/arrow.png")
var inactive_texture : Texture = load("res://scenes/path_line/line segment - gray.png")

const active_speed := 0.75
const inactive_speed := 0.25

func show_as_active():
	texture = active_texture
	self.material.set_shader_parameter("speed", active_speed)

func show_as_inactive():
	texture = inactive_texture
	self.material.set_shader_parameter("speed", inactive_speed)

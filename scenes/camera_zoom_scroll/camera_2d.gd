extends Camera2D

@onready var level_tilemap : TileMapLayer = %GroundTileMap
@onready var viewport_size = get_viewport().size

# Edge pan
var threshold = 50
var step = 2
# Screen drag
var position_before_drag
var position_before_drag2

func _ready():
	#--- Need to know when the viewport size changed so that edge scrolling works even after zoom in/out.
	get_tree().root.size_changed.connect(_on_viewport_size_changed1)
	get_viewport().size_changed.connect(_on_viewport_size_changed2)
	
	var level_region  = level_tilemap.get_used_rect()
	var tile_size     = level_tilemap.tile_set.tile_size
	#--- Point is center of tile, not edge, so adjust by 1/2 tile size to get to edge.
	#--- Don't go all the way to the edge. Don't want to see the spawn area.
	self.limit_top    = level_tilemap.map_to_local(level_region.position).y + (1*(tile_size.y / 2))
	self.limit_left   = level_tilemap.map_to_local(level_region.position).x + (1*(tile_size.x / 2))
	self.limit_bottom = level_tilemap.map_to_local(level_region.end).y - (3*(tile_size.y / 2))
	self.limit_right  = level_tilemap.map_to_local(level_region.end).x - (3*(tile_size.x / 2))

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("zoom_in"):
		zoom += Vector2(0.1, 0.1)
	elif event.is_action_pressed("zoom_out"):
		if zoom > Vector2(1, 1):
			zoom -= Vector2(0.1, 0.1)
	elif event is InputEventMagnifyGesture:
		if event.factor > 1:
			zoom += Vector2(0.1, 0.1)
		elif event.factor < 1:
			if zoom > Vector2(1, 1):
				zoom -= Vector2(0.1, 0.1)
	elif event.is_action_pressed("camera_drag"):
		#print("is_action_pressed(camera_drag)")
		position_before_drag = event.global_position
		position_before_drag2 = self.global_position
		#print("moving to "+ str(get_global_mouse_position()))
		#self.global_position = get_global_mouse_position()
	elif event.is_action_released("camera_drag"):
		#print("is_action_RELEASED(camera_drag)")
		position_before_drag = null
		
	if position_before_drag and (event is InputEventMouseMotion):
		var change = (position_before_drag - event.global_position) * (1.0/zoom.x)
		self.global_position = position_before_drag2 + change
		#self.global_position = get_global_mouse_position()

func _process(_delta):
	pass
	#var mouse_pos = get_local_mouse_position()
	#var mouse_pos = get_global_mouse_position()
	#print("mouse position="+str(mouse_pos))
	#if mouse_pos.x < threshold:
		#position.x -= step
	#elif mouse_pos.x > viewport_size.x - threshold:
		#position.x += step
	#if mouse_pos.y < threshold:
		#position.y -= step
	#elif mouse_pos.y > viewport_size.y - threshold:
		#position.y += step

func _on_viewport_size_changed1(): 
	viewport_size = get_viewport().size
	print("viewport1=" + str(viewport_size))

func _on_viewport_size_changed2(): 
	viewport_size = get_viewport().size
	print("viewport2=" + str(viewport_size))

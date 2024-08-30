extends TileMapLayer

#--- Magic numbers, specific to each project/game/tileset. Ick. 
const target_aiming_source_id := 10
const target_aiming_outlined_source_id := 9
const target_x_source_id := 11
const target_x_outlined_source_id := 12
const down_arrow_source_id := 24
const left_arrow_source_id := 25
const right_arrow_source_id := 26
const up_arrow_source_id := 27
const white_tile_source_id := 23
var tile_outline_source_id := 20 # 15, 20-22

var tile_data := {}
var path_1 : Array[Vector2i]
var path_2 : Array[Vector2i]

var desired_tile_border_width

@export_group("Colors")
#@export var range_color := Color.GREEN
@export var covered_path_color := Color.GREEN
@export var covered_not_path_color := Color(0.745098, 0.745098, 0.745098, 0.25)
@export var uncovered_path_color := Color.RED

## Should we look up the values at runtime so that each cell sharing the same tile can look different?
func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	if !tile_data.keys().has(coords): 
		return 0
	return 1

func _tile_data_runtime_update(coords: Vector2i, base_tile_data: TileData) -> void:
	if !tile_data.keys().has(coords): 
		return
	var tile_datum = tile_data[coords]
	if tile_datum["in_range"]:
		if tile_datum["on_path"]:
			base_tile_data.modulate =  covered_path_color
		else:
			base_tile_data.modulate =  covered_not_path_color
	elif tile_datum["on_path"]:
		base_tile_data.modulate =  uncovered_path_color


###################
# TILE BORDERS
###################
func set_border_tile():
	match desired_tile_border_width:
		3:
			tile_outline_source_id = 15
		5:
			tile_outline_source_id = 20
		8:
			tile_outline_source_id = 21
		10:
			tile_outline_source_id = 22
		_: 
			tile_outline_source_id = 15

func show_non_path_coverage_borders():
	set_border_tile()
	for coord in tile_data.keys():
		var tile_datum = tile_data[coord]
		if tile_datum["in_range"] and !tile_datum["on_path"]:
			set_cell(coord, tile_outline_source_id, Vector2i(0, 0))

func show_path_coverage_borders():
	set_border_tile()
	for coord in tile_data.keys():
		var tile_datum = tile_data[coord]
		if tile_datum["in_range"] and tile_datum["on_path"]:
			set_cell(coord, tile_outline_source_id, Vector2i(0, 0))

func show_path_no_coverage_borders():
	set_border_tile()
	for coord in tile_data.keys():
		var tile_datum = tile_data[coord]
		if !tile_datum["in_range"] and tile_datum["on_path"]:
			set_cell(coord, tile_outline_source_id, Vector2i(0, 0))

func show_range_borders():
	set_border_tile()
	for coord in tile_data.keys():
		var tile_datum = tile_data[coord]
		if tile_datum["in_range"]:
			set_cell(coord, tile_outline_source_id, Vector2i(0, 0))


###################
# MARKERS
###################
func show_path_coverage_targets():
	for coord in tile_data.keys():
		var tile_datum = tile_data[coord]
		if tile_datum["in_range"] and tile_datum["on_path"]:
			set_cell(coord, target_aiming_outlined_source_id, Vector2i(0, 0))

func show_non_path_coverage_targets():
	for coord in tile_data.keys():
		var tile_datum = tile_data[coord]
		if tile_datum["in_range"] and !tile_datum["on_path"]:
			set_cell(coord, target_x_outlined_source_id, Vector2i(0, 0))


###################
# ARROWS
###################
func show_path_arrows():
	uncovered_path_color.a = 1.0
	covered_path_color.a   = 1.0
	show_path_arrows_for_path(path_1)
	show_path_arrows_for_path(path_2)

func show_dim_path_arrows():
	uncovered_path_color.a = 0.50
	covered_path_color.a   = 0.50
	show_path_arrows_for_path(path_1)
	show_path_arrows_for_path(path_2)

func show_path_arrows_for_path(path: Array[Vector2i]):
	for i in range(1, path.size()-1):
		var coord := path[i]
		var next_coord := path[i+1]
		var change : Vector2i = next_coord - coord
		if change.x > 0:
			set_cell(coord, right_arrow_source_id, Vector2i(0, 0))
		elif change.x < 0:
			set_cell(coord, left_arrow_source_id, Vector2i(0, 0))
		elif change.y < 0:
			set_cell(coord, up_arrow_source_id, Vector2i(0, 0))
		else:
			set_cell(coord, down_arrow_source_id, Vector2i(0, 0))
		#var tile_datum = tile_data[coord]
		#if tile_datum["on_path"]:


###################
# SHADING
###################
func show_dim_colors(should_dim_shade: bool):
	if should_dim_shade:
		covered_not_path_color.a = 0.50
		covered_path_color.a     = 0.50
		uncovered_path_color.a   = 0.50
	else:
		covered_not_path_color.a = 1
		covered_path_color.a     = 1
		uncovered_path_color.a   = 1

func show_path_colors():
	show_path_colors_for_path(path_1)
	show_path_colors_for_path(path_2)

func show_path_colors_for_path(path: Array[Vector2i]):
	for coord in path:
		set_cell(coord, white_tile_source_id, Vector2i(0, 0))

func show_range_colors():
	for coord in tile_data.keys():
		var tile_datum = tile_data[coord]
		if tile_datum["in_range"]:
			set_cell(coord, white_tile_source_id, Vector2i(0, 0))

extends Position2D

class_name Sensor

var tiles = preload("res://singletons/tile_map_info.tres")
var collision_table = preload("res://assets/tile_sets/collision.bmp")


export(int, "right", "up", "left", "down") var starting_direction = Direction.DOWN
export(bool) var auto_adjust = false
export(int, 0, 1) var layer = 0

var direction_vec: Vector2
var _starting_direction_vec: Vector2
var direction = 0

func _ready():
	direction = starting_direction
	direction_vec = Direction.to_vec(starting_direction)
	_starting_direction_vec = direction_vec


#warning-ignore:unused_argument
func _process(delta):
	update()

func _draw():
	var pos = to_local(global_position.floor())
	draw_rect(Rect2(pos, Vector2(1, 1)), Color.red)
	
	
func set_direction_rotation(rotation_direction):
	var rot = Direction.to_vec(rotation_direction)
	direction = (starting_direction + rotation_direction) % 4
	direction_vec.x = _starting_direction_vec.x * rot.x - _starting_direction_vec.y * rot.y
	direction_vec.y = _starting_direction_vec.x * rot.y + _starting_direction_vec.y * rot.x 


func _get_tile_info(tile_coord, pixel_coord):
	var collision_map = tiles.collisions[layer]
	var id = collision_map.get_cellv(tile_coord)
	if id == -1: 
		return {
			mag = 0,
			angle = 0,
		}
		
	var transposed = collision_map.is_cell_transposed(tile_coord.x, tile_coord.y)
	var x_flip = collision_map.is_cell_x_flipped(tile_coord.x, tile_coord.y)
	var y_flip = collision_map.is_cell_y_flipped(tile_coord.x, tile_coord.y)
	var meta = collision_table.data[id]
	
	var x_mags
	var y_mags
	
	if !transposed:
		x_mags = meta.widths
		y_mags = meta.heights
	else:
		x_mags = meta.heights
		y_mags = meta.widths
		
	var mag
	if is_horizontal():
		if !y_flip:
			mag = x_mags[pixel_coord.y]
		else:
			mag = x_mags[15 - pixel_coord.y]
	else:
		if !x_flip:
			mag = y_mags[pixel_coord.x]
		else:
			mag = y_mags[15 - pixel_coord.x]
		
	var actual_angle = meta.angle
	if actual_angle != 255:
		if transposed:
			actual_angle = 64 - actual_angle
		if x_flip:
			actual_angle = 256 - actual_angle
		if y_flip:
			actual_angle = posmod(128 - actual_angle, 256)
		 
	return {
		mag = mag, 
		angle = actual_angle
	}
	

func _get_pixel_dist(pixel_coord):
	match direction:
		Direction.UP:
			return pixel_coord.y
		Direction.DOWN:
			return 15 - pixel_coord.y
		Direction.LEFT:
			return pixel_coord.x
		Direction.RIGHT:
			return 15 - pixel_coord.x


func is_horizontal():
	return Direction.is_horizontal(direction)

func get_offset_collision_info(offset):
	var map_position = tiles.map.to_local(global_position + offset).floor()
	var tile_coord = tiles.map.world_to_map(map_position)
	var pixel_coord = Vector2(int(map_position.x) % 16, int(map_position.y) % 16)
	var pixel_dist = _get_pixel_dist(pixel_coord)
	 
	var cur_info = _get_tile_info(tile_coord, pixel_coord)
	
	if auto_adjust:
		match cur_info.mag:
			0:
				var ext_info = _get_tile_info(tile_coord + direction_vec, pixel_coord)
				return {
					distance = 16 - ext_info.mag + pixel_dist,
					angle = ext_info.angle,
					sensor = self,
				}
			16:
				var ret_info = _get_tile_info(tile_coord - direction_vec, pixel_coord)
				return {
					distance = -(ret_info.mag + 16 - pixel_dist),
					angle = ret_info.angle if ret_info.mag > 0 else cur_info.angle,
					sensor = self
				}
	
	return {
		distance = pixel_dist - cur_info.mag,
		angle = cur_info.angle,
		sensor = self
	}
	
	
func get_collision_info():
	return get_offset_collision_info(Vector2.ZERO)

extends Position2D

enum Direction {
	DOWN = 0,
	RIGHT = 1,
	UP = 2,
	LEFT = 3,
}

export(Direction) var starting_direction = Direction.DOWN
export(bool) var auto_adjust = false

var _starting_direction_vec: Vector2
var _direction_vec: Vector2
var _direction = 0

func _ready():
	_direction_vec = _direction_to_vec(starting_direction)
	_starting_direction_vec = _direction_vec


func set_direction_rotation(rotation_direction):
	var rot = _direction_to_vec(rotation_direction)
	_direction = (starting_direction + rotation_direction) % 4
	_direction_vec.x = _starting_direction_vec.x * rot.x - _starting_direction_vec.y * rot.y
	_direction_vec.y = _starting_direction_vec.x * rot.y + _starting_direction_vec.y * rot.x 


func _get_tile_info(tile_coord, pixel_coord, tile_map, tile_meta_array):
	var id = tile_map.get_cellv(tile_coord)
	if id == -1: 
		return {
			mag = 0,
			angle = 0,
		}
		
	var x_flip = tile_map.is_cell_x_flipped(tile_coord.x, tile_coord.y)
	var y_flip = tile_map.is_cell_y_flipped(tile_coord.x, tile_coord.y)
	var meta = tile_meta_array[id]
	
	var mag
	if is_horizontal():
		if !y_flip:
			mag = meta.widths[pixel_coord.y]
		else:
			mag = meta.widths[15 - pixel_coord.y]
	else:
		if !x_flip:
			mag = meta.heights[pixel_coord.x]
		else:
			mag = meta.heights[15 - pixel_coord.x]
		
	var angle_flip = 1 if x_flip == y_flip else -1
	return {
		mag = mag, 
		angle = (meta.angle - 0.5 * _direction) * PI * angle_flip
	}
	

func _get_pixel_dist(pixel_coord):
	match _direction:
		Direction.UP:
			return pixel_coord.y
		Direction.DOWN:
			return 15 - pixel_coord.y
		Direction.LEFT:
			return pixel_coord.x
		Direction.RIGHT:
			return 15 - pixel_coord.x


func is_horizontal():
	return _direction == Direction.LEFT || _direction == Direction.RIGHT

func get_collision_info(tile_map, tile_meta_array):
	var map_position = tile_map.to_local(global_position).floor()
	var tile_coord = tile_map.world_to_map(map_position)
	var pixel_coord = Vector2(int(map_position.x) % 16, int(map_position.y) % 16)
	var pixel_dist = _get_pixel_dist(pixel_coord)
	 
	var cur_info = _get_tile_info(tile_coord, pixel_coord, tile_map, tile_meta_array)
	match cur_info.mag:
		0:
			var ext_info = _get_tile_info(tile_coord + _direction_vec, pixel_coord, tile_map, tile_meta_array)
			return {
				distance = 16 - ext_info.mag + pixel_dist,
				angle = ext_info.angle
			}
		16:
			var ret_info = _get_tile_info(tile_coord - _direction_vec, pixel_coord, tile_map, tile_meta_array)
			return {
				distance = -(ret_info.mag + 16 - pixel_dist),
				angle = ret_info.angle if ret_info.mag > 0 else cur_info.angle
			}
		_:
			return {
				distance = pixel_dist - cur_info.mag,
				angle = cur_info.angle
			}
	

static func _direction_to_vec(direction):
	match direction:
		Direction.UP:
			return Vector2.UP
		Direction.DOWN:
			return Vector2.DOWN
		Direction.LEFT:
			return Vector2.LEFT
		Direction.RIGHT:
			return Vector2.RIGHT

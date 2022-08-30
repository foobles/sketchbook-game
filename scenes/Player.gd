extends Node2D


var ground_speed: float = 0.0
var angle: int = 0
var velocity: Vector2 = Vector2()

var input_h = 0
var input_v = 0

onready var sprite = $Sprite
onready var _state = $State

#warning-ignore:unused_argument
func _process(delta):
	input_h = \
		int(Input.is_action_pressed("control_move_right")) \
		- int(Input.is_action_pressed("control_move_left"))
		
	input_v = \
		int(Input.is_action_pressed("control_move_down")) \
		- int(Input.is_action_pressed("control_move_up"))
		
	_state.animate_player(self)		
	sprite.global_position = global_position.floor()
	

func set_animation(anim):
	if $AnimationPlayer.current_animation != anim:
		$AnimationPlayer.play(anim)


func set_animation_ticks(n):
	$AnimationPlayer.playback_speed = 60.0 / (n + 1)


const _OCT = 32
func get_current_direction():
	if angle <= _OCT || angle >= 7*_OCT:
		return 0
	elif 3*_OCT <= angle && angle <= 5*_OCT:
		return 2
	elif _OCT < angle && angle < 3*_OCT:
		return 1
	else:
		return 3


func get_angle_rads():
	return float(angle) / 128.0 * PI


func tick_physics(tile_map, tile_meta_array):
	_state.update_player(self, tile_map, tile_meta_array)




func prevent_wall_collision(wall_sensor, tile_map, tile_meta_array):
	var info = wall_sensor.get_offset_collision_info(velocity, tile_map, tile_meta_array)
	if info.distance < 0:
		ground_speed = 0
		velocity += info.distance * wall_sensor.direction_vec
		


func snap_to_floor(foot_sensors, tile_map, tile_meta_array):
	var chosen_result = null
	var chosen_sensor = null
	for sensor in foot_sensors:
		var cur_result = sensor.get_collision_info(tile_map, tile_meta_array)
		if cur_result.distance > 14:
			continue
		if chosen_result == null || cur_result.distance < chosen_result.distance:
			chosen_result = cur_result
			chosen_sensor = sensor
	
	if chosen_result != null:
		position += chosen_result.distance * chosen_sensor.direction_vec
		angle = chosen_result.angle
		
	return chosen_result

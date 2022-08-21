extends Node2D

export(float) var walk_accel = 0.046875
export(float) var walk_decel = 0.5
export(float) var walk_friction = 0.046875
export(float) var max_walk_veloc = 6.0
export(float) var slope_factor = 0.125

export(float) var standing_slope_slip_threshold = 0.05078125

var ground_speed: float = 0.0
var angle: int = 0
var velocity: Vector2 = Vector2()

var input_direction = 0

onready var foot_sensors = [$Sensors/FootLeft, $Sensors/FootRight]
onready var head_sensors = []
onready var right_sensor = $Sensors/WallRight
onready var left_sensor = $Sensors/WallLeft


#warning-ignore:unused_argument
func _process(delta):
	input_direction = \
		int(Input.is_action_pressed("control_move_right")) \
		- int(Input.is_action_pressed("control_move_left"))
		
	$Sprite.rotation = -stepify(_get_angle_rads(), 0.25*PI)
	
	if is_zero_approx(ground_speed):
		if $AnimationPlayer.current_animation != "idle":
			$AnimationPlayer.play("idle")
	else:
		$Sprite.flip_h = (ground_speed < 0)
		if abs(ground_speed) >= max_walk_veloc:
			if $AnimationPlayer.current_animation != "run":
				$AnimationPlayer.play("run")
		else:
			if $AnimationPlayer.current_animation != "walk":
				$AnimationPlayer.play("walk")
				
	$Sprite.global_position = global_position.floor()
			
	
	$AnimationPlayer.playback_speed = floor(8.0 / (8.0 - abs(ground_speed)))
		

func update_velocity():
	var angle_rads = _get_angle_rads()
	var slope_accel = sin(angle_rads) * slope_factor
	if !is_zero_approx(ground_speed) || abs(slope_accel) >= standing_slope_slip_threshold:
		ground_speed -= slope_accel
	
	if input_direction != 0:
		if sign(input_direction) != -sign(ground_speed):
			if abs(ground_speed) < max_walk_veloc:
				ground_speed += input_direction * walk_accel
				ground_speed = clamp(ground_speed, -max_walk_veloc, max_walk_veloc)
				
		else:
			if abs(ground_speed) >= walk_decel:
				ground_speed += input_direction * walk_decel
			else:
				ground_speed = input_direction * 0.5
	else:
		if abs(ground_speed) > walk_friction:
			ground_speed -= sign(ground_speed) * walk_friction 
		else:
			ground_speed = 0
			
	velocity = ground_speed * Vector2(cos(angle_rads), -sin(angle_rads))
	

func apply_velocity():
	position += velocity

func snap_to_geometry(tile_map, tile_meta_array):
	if ground_speed < 0:
		snap_out_wall(left_sensor, tile_map, tile_meta_array)
	elif ground_speed > 0:
		snap_out_wall(right_sensor, tile_map, tile_meta_array)
	
	var chosen_result = null
	for sensor in foot_sensors:
		var cur_result = sensor.get_collision_info(tile_map, tile_meta_array)
		if cur_result.distance > 14:
			continue
		if chosen_result == null || cur_result.distance < chosen_result.distance:
			chosen_result = cur_result
	
	if chosen_result != null:
		position += chosen_result.distance * $Sensors/FootLeft.direction_vec
		angle = chosen_result.angle
		var nearest_dir = _current_dir()
		$Sensors.rotation_degrees = -nearest_dir * 90
		for sensor in $Sensors.get_children():
			sensor.set_direction_rotation(nearest_dir)


func snap_out_wall(wall_sensor, tile_map, tile_meta_array):
	var info = wall_sensor.get_collision_info(tile_map, tile_meta_array)
	if info.distance < 0:
		ground_speed = 0
		position += info.distance * wall_sensor.direction_vec

const _OCT = 32
func _current_dir():
	if angle <= _OCT || angle >= 7*_OCT:
		return 0
	elif 3*_OCT <= angle && angle <= 5*_OCT:
		return 2
	elif _OCT < angle && angle < 3*_OCT:
		return 1
	else:
		return 3


func _get_angle_rads():
	return float(angle) / 128.0 * PI

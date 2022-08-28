extends Node2D


var ground_speed: float = 0.0
var angle: int = 0
var velocity: Vector2 = Vector2()

var input_direction = 0

onready var _pose = $Pose

#warning-ignore:unused_argument
func _process(delta):
	input_direction = \
		int(Input.is_action_pressed("control_move_right")) \
		- int(Input.is_action_pressed("control_move_left"))
		
	$Sprite.rotation = -stepify(_get_angle_rads(), 0.25*PI)
	
	if is_zero_approx(ground_speed):
		if $AnimationPlayer.current_animation != _pose.idle_anim:
			$AnimationPlayer.play(_pose.idle_anim)
	else:
		$Sprite.flip_h = (ground_speed < 0)
		if abs(ground_speed) >= _pose.max_walk_speed:
			if $AnimationPlayer.current_animation != _pose.run_anim:
				$AnimationPlayer.play(_pose.run_anim)
		else:
			if $AnimationPlayer.current_animation != _pose.walk_anim:
				$AnimationPlayer.play(_pose.walk_anim)
				
	$Sprite.global_position = global_position.floor()
	
	
	$AnimationPlayer.playback_speed = 60.0 / (max(0.0, floor(4.0 - abs(ground_speed))) + 1)
	

func update_velocity(tile_map, tile_meta_array):
	_pose.update_constants(self)
	
	apply_slope_factor()
	
	if is_accelerating():
		apply_acceleration()
	elif is_decelerating():
		apply_deceleration()
	else:
		apply_friction()
		
	var angle_rads = _get_angle_rads()
	velocity = ground_speed * Vector2(cos(angle_rads), -sin(angle_rads))
	
	if _pose.left_sensor.direction_vec.dot(velocity) > 0:
		prevent_wall_collision(_pose.left_sensor, tile_map, tile_meta_array)
	elif _pose.right_sensor.direction_vec.dot(velocity) > 0:
		prevent_wall_collision(_pose.right_sensor, tile_map, tile_meta_array)
	

func apply_slope_factor():
	var angle_rads = _get_angle_rads()
	var slope_accel = _pose.slope_factor * sin(angle_rads)
	if ground_speed != 0 || abs(slope_accel) >= _pose.standing_slope_slip_threshold:
		ground_speed -= slope_accel


func is_accelerating():
	var walk_accel = _pose.walk_accel
	return (
		walk_accel != null
		&& input_direction != 0
		&& input_direction != -sign(ground_speed)
	)


func is_decelerating():
	var walk_decel = _pose.walk_decel
	return (
		walk_decel != null
		&& input_direction != 0
		&& input_direction == -sign(ground_speed)
	)


func apply_acceleration():
	var max_walk_speed = _pose.max_walk_speed
	if abs(ground_speed) < max_walk_speed:
		ground_speed += input_direction * _pose.walk_accel
		ground_speed = clamp(ground_speed, -max_walk_speed, max_walk_speed)
	

func apply_deceleration():
	var walk_decel = _pose.walk_decel
	if abs(ground_speed) > walk_decel:
		ground_speed += input_direction * walk_decel
	else:
		ground_speed = input_direction * 0.5


func apply_friction():
	var walk_friction = _pose.walk_friction
	if abs(ground_speed) > walk_friction:
		ground_speed -= sign(ground_speed) * walk_friction
	else:
		ground_speed = 0.0

	
func prevent_wall_collision(wall_sensor, tile_map, tile_meta_array):
	var info = wall_sensor.get_offset_collision_info(velocity, tile_map, tile_meta_array)
	if info.distance < 0:
		ground_speed = 0
		velocity += info.distance * wall_sensor.direction_vec


func apply_velocity():
	position += velocity


func snap_to_floor(tile_map, tile_meta_array):
	var chosen_result = null
	for sensor in _pose.foot_sensors:
		var cur_result = sensor.get_collision_info(tile_map, tile_meta_array)
		if cur_result.distance > 14:
			continue
		if chosen_result == null || cur_result.distance < chosen_result.distance:
			chosen_result = cur_result
	
	if chosen_result != null:
		position += chosen_result.distance * _pose.get_foot_direction_vec()
		set_angle(chosen_result.angle)


func set_angle(new_angle):
	angle = new_angle
	_pose.update_direction(self)
	


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


func _get_angle_rads():
	return float(angle) / 128.0 * PI

extends Node2D

export(float) var walk_accel = 0.046875
export(float) var walk_decel = 0.5
export(float) var walk_friction = 0.046875
export(float) var max_walk_veloc = 6.0
export(float) var slope_factor = 0.125

export(float) var standing_slope_slip_threshold = 0.05078125

var ground_speed: float = 0.0
var angle: float = -atan(0.5) 

var input_direction = 0


func _process(delta):
	input_direction = \
		int(Input.is_action_pressed("control_move_right")) \
		- int(Input.is_action_pressed("control_move_left"))
		
	$Sprite.rotation = stepify(-angle, 0.25 * PI)
	
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
		

func update_ground_speed():
	var slope_accel = sin(angle) * slope_factor
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
	


func apply_ground_speed():
	position += ground_speed * Vector2(cos(angle), -sin(angle))


func snap_to_floor(tile_map, tile_meta_array):
	var left_result = $Sensors/FootLeft.get_collision_info(tile_map, tile_meta_array)
	var right_result = $Sensors/FootRight.get_collision_info(tile_map, tile_meta_array)
	
	var chosen_result = \
		left_result if left_result.distance < right_result.distance else right_result
	
	position += chosen_result.distance * $Sensors/FootLeft.direction_vec
	angle = chosen_result.angle
	
	
	var nearest_dir = _current_dir()
	$Sensors.rotation_degrees = -nearest_dir * 90
	for sensor in $Sensors.get_children():
		sensor.set_direction_rotation(nearest_dir)


func _current_dir():
	var a = fposmod(angle / PI, 2)
	if is_equal_approx(a, 0.25) || is_equal_approx(a, 1.75) || a < 0.25 || a > 1.75:
		return 0
	elif is_equal_approx(a, 0.75) || is_equal_approx(a, 1.25) || (0.75 < a && a < 1.25):
		return 2
	elif 0.25 < a && a < 0.75:
		return 1
	else:
		return 3

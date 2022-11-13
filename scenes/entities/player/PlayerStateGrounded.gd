extends "res://scenes/entities/player/PlayerState.gd"

const Player = preload("res://scenes/entities/player/Player.gd")

const SLIP_SPEED_THRESHOLD: float = 2.5
const SLIP_ANGLE_THRESHOLD: int = 32
const ROLL_SPEED_THRESHOLD: float = 0.5

func enter_state(player):
	player.pose.direction = player.get_current_direction()
	player.set_grounded(true)


func snap_to_floor(player, rolling):
	var collision = null
	for sensor in player.pose.foot_sensors:
		var cur = sensor.get_collision_info()
		if cur.distance > 14:
			continue
		if collision == null || cur.distance < collision.distance:
			collision = cur

	if collision != null:
		player.apply_floor_collision(collision)
		player.pose.direction = player.get_current_direction()
	else:
		player.state_airborne.transition_no_floor(player, rolling)
		pass


func prevent_wall_collision(player, wall_sensor):
	var info = wall_sensor.get_offset_collision_info(player.velocity)
	if info.distance < 0:
		player.ground_speed = 0
		player.velocity += info.distance * wall_sensor.direction_vec
	
	
func prevent_wall_collision_from_active_sensor(player):
	var pose = player.pose
	if pose.left_sensor.direction_vec.dot(player.velocity) > 0:
		prevent_wall_collision(player, pose.left_sensor)
	elif pose.right_sensor.direction_vec.dot(player.velocity) > 0:
		prevent_wall_collision(player, pose.right_sensor)


func check_slipping(player, rolling, slip_speed_threshold, slip_angle_threshold):
	if player.control_lock == 0:
		if (slip_angle_threshold < player.angle 
			&& player.angle < 256 - slip_angle_threshold
			&& abs(player.ground_speed) < slip_speed_threshold
		):
			player.control_lock = 30
			player.state_airborne.transition_no_floor(player, rolling)
	else:
		player.control_lock -= 1


func check_jump(player):
	if player.jump_just_pressed && is_head_clear_for_jump(player):
		player.look_direction = 0
		player.state_airborne.transition_jump(player)
		return true
	else:
		return false


func is_accelerating(player):
	return (
		!player.is_control_locked()
		&& player.input_h != 0
		&& player.input_h != -sign(player.ground_speed)
	)


func is_decelerating(player):
	return (
		!player.is_control_locked()
		&& player.input_h != 0
		&& player.input_h == -sign(player.ground_speed)
	)


func apply_acceleration(player, accel):
	var run_speed = Player.RUN_SPEED
	if abs(player.ground_speed) < run_speed:
		player.ground_speed += player.input_h * accel
		player.ground_speed = clamp(player.ground_speed, -run_speed, run_speed)
	

func is_head_clear_for_jump(player):
	for sensor in player.pose.head_sensors:
		if sensor.get_collision_info().distance <= 0:
			return false
	return true


func apply_deceleration(player, decel):
	if abs(player.ground_speed) > decel:
		player.ground_speed += player.input_h * decel
	else:
		player.ground_speed = player.input_h * 0.5
		

func apply_friction(player, friction):
	if abs(player.ground_speed) > friction:
		player.ground_speed -= sign(player.ground_speed) * friction
	else:
		player.ground_speed = 0.0
		
		
func update_animation_direction(player):
	player.sprite.flip_h = (sign(player.direction) == -1)
	player.set_animation_reversed((player.direction * player.ground_speed) < 0)

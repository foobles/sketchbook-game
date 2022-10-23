extends "res://scenes/entities/player/PlayerState.gd"

const Player = preload("res://scenes/entities/player/Player.gd")

const SLIP_SPEED_THRESHOLD: float = 2.5
const SLIP_ANGLE_THRESHOLD: int = 32

class PoseInfo:
	var dimensions
	var accel
	var decel
	var friction
	var slope_factor
	var standing_slope_slip_threshold
	
	func update_constants(_player):
		pass
		
	func animate_player(_player):
		pass
		
	func transition_inner(_player, _grounded):
		pass
	
	
class PoseInfoStand extends PoseInfo:
	func _init():
		dimensions = Player.STAND_DIMENSIONS
		accel = 12 / 256.0 
		decel = 128 / 256.0 
		friction = 12 / 256.0 
		slope_factor = 32 / 256.0
		standing_slope_slip_threshold = 13 / 256.0
	
	func animate_player(player):
		player.animate_walking()
		
	
	func transition_inner(player, grounded):
		if player.ground_speed != 0 && player.input_v == 1:
			grounded._set_inner_state(player, grounded._info_ball)


class PoseInfoBall extends PoseInfo:
	func _init():
		dimensions = Player.BALL_DIMENSIONS
		accel = null 
		decel = 32 / 256.0 
		friction = 6 / 256.0 
		standing_slope_slip_threshold = 0 / 256.0


	func update_constants(player):
		if (player.angle < 128) == (player.ground_speed > 0):
			slope_factor = 20 / 256.0
		else:
			slope_factor = 80 / 256.0


	func animate_player(player):
		player.animate_rolling()
		

	func transition_inner(player, grounded):
		if player.ground_speed == 0:
			grounded._set_inner_state(player, grounded._info_stand)


var _info_stand = PoseInfoStand.new()
var _info_ball = PoseInfoBall.new()
var _inner_state = _info_stand

func _set_inner_state(player, pose_info):
	var old_direction = player.pose.direction
	player.set_dimensions(pose_info.dimensions)
	player.pose.direction = old_direction
	_inner_state = pose_info
	
	
func transition_land_from_air_floor(player):
	var r_angle = player.angle
	if r_angle > 128:
		r_angle = 256 - r_angle
	
	if r_angle < 16:
		player.ground_speed = player.velocity.x
	else:
		if player.get_movement_direction() % 2 == 0:
			player.ground_speed = player.velocity.x
		else:
			player.ground_speed = player.velocity.y 
			player.ground_speed *= -1 if player.angle < 128 else 1
			player.ground_speed *= 0.5 if r_angle < 32 else 1.0
			
	player.set_state(self)


func transition_land_from_air_ceiling(player):
	var r_angle = player.angle
	if r_angle > 128:
		r_angle = 256 - r_angle
	
	if 64 <= r_angle && r_angle < 96:
		player.ground_speed = player.velocity.y
		player.ground_speed *= -1 if player.angle < 128 else 1
		player.set_state(self)
	else:
		player.velocity.y = 0
		
		
func transition_land_on_object(player, object):
	player.stood_object = object
	player.velocity.y = 0
	player.ground_speed = player.velocity.x
	player.angle = 0
	player.set_state(self)



func enter_state(player):
	player.set_dimensions(Player.STAND_DIMENSIONS)
	player.pose.direction = player.get_current_direction()
	_inner_state = _info_stand	
	player.set_grounded(true)
	
	
func update_player(player):
	_inner_state.update_constants(player)
	
	apply_slope_factor(player)
	
	if player.jump_just_pressed:
		player.state_airborne.transition_jump(player)
		return
	
	if is_accelerating(player):
		apply_acceleration(player)
	elif is_decelerating(player):
		apply_deceleration(player)
	else:
		apply_friction(player)
		
	var angle_rads = player.get_angle_rads()
	player.velocity = player.ground_speed * Vector2(cos(angle_rads), -sin(angle_rads))
	
	_inner_state.transition_inner(player, self)
	
	var pose = player.pose
	if pose.left_sensor.direction_vec.dot(player.velocity) > 0:
		prevent_wall_collision(player, pose.left_sensor)
	elif pose.right_sensor.direction_vec.dot(player.velocity) > 0:
		prevent_wall_collision(player, pose.right_sensor)
	
	player.position += player.velocity
	if player.stood_object == null:
		snap_to_floor(player)
	check_slipping(player)


func snap_to_floor(player):
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
		player.state_airborne.transition_no_floor(player, is_rolling())


func prevent_wall_collision(player, wall_sensor):
	var info = wall_sensor.get_offset_collision_info(player.velocity)
	if info.distance < 0:
		player.ground_speed = 0
		player.velocity += info.distance * wall_sensor.direction_vec
		

func check_slipping(player):
	if player.control_lock == 0:
		if (SLIP_ANGLE_THRESHOLD < player.angle 
			&& player.angle < 256 - SLIP_ANGLE_THRESHOLD
			&& abs(player.ground_speed) < SLIP_SPEED_THRESHOLD
		):
			player.control_lock = 30
			var airborne = player.state_airborne
			airborne.rolling = is_rolling()
			airborne.jumping = false
			player.set_state(airborne)
	else:
		player.control_lock -= 1


func apply_slope_factor(player):
	var angle_rads = player.get_angle_rads()
	var slope_accel = _inner_state.slope_factor * sin(angle_rads)
	if player.ground_speed != 0 || abs(slope_accel) >= _inner_state.standing_slope_slip_threshold:
		player.ground_speed -= slope_accel


func is_accelerating(player):
	var walk_accel = _inner_state.accel
	return (
		walk_accel != null
		&& !player.is_control_locked()
		&& player.input_h != 0
		&& player.input_h != -sign(player.ground_speed)
	)


func is_decelerating(player):
	var walk_decel = _inner_state.decel
	return (
		walk_decel != null
		&& !player.is_control_locked()
		&& player.input_h != 0
		&& player.input_h == -sign(player.ground_speed)
	)


func is_rolling():
	return _inner_state is PoseInfoBall

func apply_acceleration(player):
	var run_speed = Player.RUN_SPEED
	if abs(player.ground_speed) < run_speed:
		player.ground_speed += player.input_h * _inner_state.accel
		player.ground_speed = clamp(player.ground_speed, -run_speed, run_speed)
	

func apply_deceleration(player):
	var walk_decel = _inner_state.decel
	if abs(player.ground_speed) > walk_decel:
		player.ground_speed += player.input_h * walk_decel
	else:
		player.ground_speed = player.input_h * 0.5
		

func apply_friction(player):
	var walk_friction = _inner_state.friction
	if abs(player.ground_speed) > walk_friction:
		player.ground_speed -= sign(player.ground_speed) * walk_friction
	else:
		player.ground_speed = 0.0
		

func animate_player(player):
	player.sprite.flip_h = (sign(player.direction) == -1)
	_inner_state.animate_player(player)
	player.set_animation_reversed((player.direction * player.ground_speed) < 0)
	

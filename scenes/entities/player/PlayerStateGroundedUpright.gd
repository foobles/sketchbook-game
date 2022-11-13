extends "res://scenes/entities/player/PlayerStateGrounded.gd"

const ACCEL = 12 / 256.0 
const DECEL = 128 / 256.0 
const TOP_RUN_SPEED = 6.0
const FRICTION = 12 / 256.0 
const SLOPE_FACTOR = 32 / 256.0
const STANDING_SLOPE_SLIDE_ANGLE_THRESHOLD = 13 / 256.0

const AIRBORNE_MODE = Airborne.MODE_UPRIGHT


func enter_state(player):
	.enter_state(player)
	player.set_dimensions(Player.STAND_DIMENSIONS)

func update_player(player):
	apply_slope_factor_upright(player, SLOPE_FACTOR, STANDING_SLOPE_SLIDE_ANGLE_THRESHOLD)
	
	if check_jump(player):
		return
	
	if is_accelerating(player):
		apply_acceleration(player, ACCEL)
	elif is_decelerating(player):
		apply_deceleration(player, DECEL)
	else:
		apply_friction(player, FRICTION)
		
	transfer_ground_speed_to_velocity(player)
	
	check_rolling(player)
	
	prevent_wall_collision_from_active_sensor(player)
	player.position += player.velocity
	if player.stood_object == null:
		snap_to_floor(player, AIRBORNE_MODE)
	check_slipping(player, AIRBORNE_MODE)
	
	
func animate_player(player):
	if player.ground_speed == 0:
		player.animate_standing()
	else:
		player.animate_walking()
	update_animation_direction(player)


func apply_slope_factor_upright(player, slope_factor, slip_threshold):
	var angle_rads = player.get_angle_rads()
	var slope_accel = slope_factor * sin(angle_rads)
	if player.ground_speed != 0 || abs(slope_accel) >= slip_threshold:
		player.ground_speed -= slope_accel


func check_rolling(player):
	if player.input_v == 1 && abs(player.ground_speed) >= ROLL_SPEED_THRESHOLD:
		player.set_state(player.state_grounded_rolling)


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

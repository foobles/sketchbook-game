extends "res://scenes/entities/player/PlayerStateGrounded.gd"

const DECEL = 32 / 256.0 
const FRICTION = 6 / 256.0 
const SLOPE_FACTOR_ROLL_UP = 20 / 256.0
const SLOPE_FACTOR_ROLL_DOWN = 80 / 256.0

const IS_ROLLING = true

func enter_state(player):
	.enter_state(player)
	player.set_dimensions(Player.BALL_DIMENSIONS)
	

func update_player(player):
	apply_slope_factor_rolling(player, SLOPE_FACTOR_ROLL_UP, SLOPE_FACTOR_ROLL_DOWN)
	
	if check_jump(player):
		return
	
	if is_decelerating(player):
		apply_deceleration(player, DECEL)
	apply_friction(player, FRICTION)
		
	var angle_rads = player.get_angle_rads()
	player.velocity = player.ground_speed * Vector2(cos(angle_rads), -sin(angle_rads))
	
	check_stop_rolling(player)
	
	prevent_wall_collision_from_active_sensor(player)
	player.position += player.velocity
	if player.stood_object == null:
		snap_to_floor(player, IS_ROLLING)
	check_slipping(player, IS_ROLLING, SLIP_SPEED_THRESHOLD, SLIP_ANGLE_THRESHOLD)
	
	
func animate_player(player):
	player.animate_rolling()
	update_animation_direction(player)


func apply_slope_factor_rolling(player, slope_factor_roll_up, slope_factor_roll_down):
	var angle_sin = sin(player.get_angle_rads())
	var rolling_up = (sign(angle_sin) == sign(player.ground_speed))
	var slope_factor = slope_factor_roll_up if rolling_up else slope_factor_roll_down
	var slope_accel = angle_sin * slope_factor
	player.ground_speed -= slope_accel


func check_stop_rolling(player):
	if player.ground_speed == 0:
		player.set_state(player.state_grounded_upright)
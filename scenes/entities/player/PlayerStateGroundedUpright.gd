extends "res://scenes/entities/player/PlayerStateGrounded.gd"

const ACCEL = 12 / 256.0 
const DECEL = 128 / 256.0 
const TOP_RUN_SPEED = 6.0
const FRICTION = 12 / 256.0 
const SLOPE_FACTOR = 32 / 256.0
const STANDING_SLOPE_SLIDE_ANGLE_THRESHOLD = 13 / 256.0

const AIRBORNE_MODE = Airborne.MODE_UPRIGHT

const LOOK_DELAY = 120

enum SubState {
	IDLING, WALKING, LOOKING_UP, LOOKING_DOWN, PUSHING
}

var sub_state
var look_timer = 0
var push_direction = 0 

func enter_state(player):
	.enter_state(player)
	sub_state = SubState.WALKING
	player.set_dimensions(Player.STAND_DIMENSIONS)

func update_player(player):
	player.look_direction = 0
	update_sub_state(player)
		
	if sub_state == SubState.LOOKING_DOWN && player.jump_just_pressed:
		player.set_state(player.state_grounded_revving)
		return
	
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
	
	if prevent_wall_collision_from_active_sensor(player):
		start_pushing(player)
		
	player.position += player.velocity
	if player.stood_object == null:
		snap_to_floor(player, AIRBORNE_MODE)
	check_slipping(player, AIRBORNE_MODE)
	update_look_direction(player)
	
	
func animate_player(player):
	match sub_state:
		SubState.IDLING:
			player.animate_standing()
		SubState.WALKING:
			player.animate_walking()
		SubState.LOOKING_UP:
			player.animate_look_up()
		SubState.LOOKING_DOWN:
			player.animate_look_down()
		SubState.PUSHING:
			player.animate_pushing()
	update_animation_direction(player)


func update_sub_state(player):
	if player.input_h != 0:
		if !(sub_state == SubState.PUSHING && player.direction == push_direction):
			sub_state = SubState.WALKING
	elif abs(player.ground_speed) < 0.5 && player.input_v == 1:
		sub_state = SubState.LOOKING_DOWN
	elif player.ground_speed == 0:
		if player.input_v == -1:
			sub_state = SubState.LOOKING_UP
		else:
			sub_state = SubState.IDLING
			

func start_pushing(player):
	sub_state = SubState.PUSHING
	push_direction = player.direction
	

func update_look_direction(player):
	match sub_state:
		SubState.IDLING, SubState.WALKING, SubState.PUSHING:
			look_timer = 0
		SubState.LOOKING_UP:
			update_look_timer(player, -1)
		SubState.LOOKING_DOWN:
			update_look_timer(player, +1)
		
		
func update_look_timer(player, look_direction):
	if look_timer < LOOK_DELAY:
		look_timer += 1

	if look_timer == LOOK_DELAY:
		player.look_direction = look_direction
	
	
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

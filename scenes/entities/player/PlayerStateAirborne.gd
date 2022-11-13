extends "res://scenes/entities/player/PlayerState.gd"

const Player = preload("res://scenes/entities/player/Player.gd")

const AIR_ACCEL = 24/256.0 
const AIR_DRAG_FACTOR = 1/32.0
const AIR_GRAVITY = 56 / 256.0

const JUMP_SPEED = 6.5
const JUMP_CONTROL_VELOC = -4

const WALL_JUMP_REACTION_TIME = 5
const WALL_JUMP_BUFFER_TIME = 5

enum {
	MODE_ROLLING
	MODE_UPRIGHT
}

var mode
var jumping: bool = false
var wall_jump_timer = 0
var wall_jump_velocity = 0
var wall_jump_state 
enum WallJumpState { BUFFERED, REACTION }

func enter_state(player):
	match mode:
		MODE_ROLLING:
			player.set_dimensions(Player.BALL_DIMENSIONS)
		MODE_UPRIGHT:
			player.set_dimensions(Player.STAND_DIMENSIONS)
	player.pose.direction = 0
	player.set_grounded(false)


func update_player(player):
	if jumping && !player.jump_pressed && player.velocity.y < JUMP_CONTROL_VELOC:
		player.velocity.y = JUMP_CONTROL_VELOC
		
	if player.jump_just_pressed:
		if wall_jump_timer == 0:
			wall_jump_timer = WALL_JUMP_BUFFER_TIME
			wall_jump_state = WallJumpState.BUFFERED
		elif wall_jump_state == WallJumpState.REACTION:
			wall_jump(player, wall_jump_velocity)
	if wall_jump_timer > 0:
		wall_jump_timer -= 1
		
	
	player.velocity.x += AIR_ACCEL * player.input_h
	
	if -4 < player.velocity.y && player.velocity.y < 0:
		player.velocity.x -= player.velocity.x * AIR_DRAG_FACTOR
		
	player.position += player.velocity
	
	player.velocity.y += AIR_GRAVITY
	
	var active_sensors = get_active_sensors(player)
	for wall_sensor in active_sensors.wall_sensors:
		exit_wall(player, wall_sensor)
		
	interpolate_angle(player)
	if land_on_surface(player, active_sensors.foot_sensors, +1) && player.velocity.y > 0:
		player.state_grounded_upright.transition_land_from_air_floor(player)
	if land_on_surface(player, active_sensors.head_sensors, -1) && player.velocity.y < 0:
		player.state_grounded_upright.transition_land_from_air_ceiling(player)

	
	
func interpolate_angle(player):
	if 2 < player.angle && player.angle < 256 - 2:
		player.angle += -2 if player.angle < 128 else 2
	else:
		player.angle = 0
	
	
func transition_jump(player):
	mode = MODE_ROLLING
	jumping = true
	player.stood_object = null
	var angle_rads = player.get_angle_rads()
	player.velocity += JUMP_SPEED * Vector2(-sin(angle_rads), -cos(angle_rads))
	player.set_state(self)
	

func transition_no_floor(player, new_mode):
	mode = new_mode
	jumping = false
	player.set_state(self)
	

func land_on_surface(player, sensors, y_direction_sign):
	var movement_direction = player.get_movement_direction()
	var y_direction = 2 + y_direction_sign
	var distance_threshold = -(y_direction_sign * player.velocity.y + 8)
	
	var collision = null
	var distance_met = false
	
	for sensor in sensors:
		var cur = sensor.get_collision_info()
		if cur.distance >= distance_threshold:
			distance_met = true
			
		if cur.distance >= 0:
			continue
			
		if collision == null || cur.distance < collision.distance:
			collision = cur 
			
	if collision == null:
		return false
			
	if movement_direction == y_direction && !distance_met:
		return false
		
	if movement_direction % 2 == 0 && y_direction_sign * player.velocity.y < 0:
		return false

	player.angle = 0
	player.apply_floor_collision(collision)
	return true

func exit_wall(player, wall_sensor):
	var info = wall_sensor.get_collision_info()
	if info.distance < 0:
		player.position += info.distance * wall_sensor.direction_vec
		if player.velocity.dot(wall_sensor.direction_vec) > 0:
			
			
			if wall_jump_timer == 0:
				wall_jump_timer = WALL_JUMP_REACTION_TIME 
				wall_jump_velocity = -player.velocity.x
				wall_jump_state = WallJumpState.REACTION
				var h = wall_sensor.direction & 1
				player.velocity.x *= h
				player.velocity.y *= (h^1)
			elif wall_jump_state == WallJumpState.BUFFERED:
				wall_jump(player, -player.velocity.x)
				
	
	
func wall_jump(player, vx):
	if mode != MODE_ROLLING:
		return
	wall_jump_timer = 0
	#300.0/256
	vx = clamp(vx , -JUMP_SPEED, JUMP_SPEED)
	player.velocity.x = vx
	player.velocity.y = player.velocity.y * 0.25 -abs(vx)
	
func get_active_sensors(player):
	var pose = player.pose
	if abs(player.velocity.x) > abs(player.velocity.y):
		return {
			wall_sensors = [pose.right_sensor if player.velocity.x > 0 else pose.left_sensor],
			foot_sensors = pose.foot_sensors,
			head_sensors = pose.head_sensors
		}
	else:
		return {
			wall_sensors = [pose.right_sensor,  pose.left_sensor],
			foot_sensors = pose.foot_sensors if player.velocity.y > 0 else [],
			head_sensors = pose.head_sensors if player.velocity.y < 0 else []
		}


func animate_player(player):
	match mode:
		MODE_ROLLING:
			player.animate_rolling()
		MODE_UPRIGHT:
			player.animate_walking()

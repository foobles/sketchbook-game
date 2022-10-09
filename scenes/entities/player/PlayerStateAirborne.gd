extends "res://scenes/entities/player/PlayerState.gd"

const Player = preload("res://scenes/entities/player/Player.gd")

const AIR_ACCEL = 24/256.0 
const AIR_DRAG_FACTOR = 1/32.0
const AIR_GRAVITY = 56 / 256.0

const JUMP_SPEED = 6.5
const JUMP_CONTROL_VELOC = -4

var rolling: bool
var jumping: bool = false

func enter_state(player):
	if rolling:
		player.set_dimensions(Player.BALL_DIMENSIONS)
	else:
		player.set_dimensions(Player.STAND_DIMENSIONS)
		
	player.pose.direction = 0
	player.set_grounded(false)


func update_player(player):
	if jumping && !player.jump_pressed && player.velocity.y < JUMP_CONTROL_VELOC:
		player.velocity.y = JUMP_CONTROL_VELOC
		
	player.velocity.x += AIR_ACCEL * player.input_h
	
	if -4 < player.velocity.y && player.velocity.y < 0:
		player.velocity.x -= player.velocity.x * AIR_DRAG_FACTOR
		
	player.position += player.velocity
	
	player.velocity.y += AIR_GRAVITY
	
	var active_sensors = get_active_sensors(player)
	for wall_sensor in active_sensors.wall_sensors:
		exit_wall(player, wall_sensor)
		
	interpolate_angle(player)
	land_on_ground(player, active_sensors.foot_sensors)
	
	
func interpolate_angle(player):
	if 2 < player.angle && player.angle < 256 - 2:
		player.angle += -2 if player.angle < 128 else 2
	else:
		player.angle = 0
	
	
func transition_jump(player):
	rolling = true
	jumping = true
	player.stood_object = null
	var angle_rads = player.get_angle_rads()
	player.velocity += JUMP_SPEED * Vector2(-sin(angle_rads), -cos(angle_rads))
	player.set_state(self)
	

func transition_no_floor(player, was_rolling):
	rolling = was_rolling
	jumping = false
	player.set_state(self)
	

func land_on_ground(player, foot_sensors):
	var movement_direction = player.get_movement_direction()
	var downwards_distance_threshold = -(player.velocity.y + 8)
	
	var collision = null
	var downwards_distance_met = false
	
	for sensor in foot_sensors:
		var cur = sensor.get_collision_info()
		if cur.distance >= downwards_distance_threshold:
			downwards_distance_met = true
			
		if cur.distance >= 0:
			continue
			
		if collision == null || cur.distance < collision.distance:
			collision = cur 
			
	if collision == null:
		return
			
	if movement_direction == 3 && !downwards_distance_met:
		return
		
	if movement_direction % 2 == 0 && player.velocity.y < 0:
		return

	player.angle = 0
	player.apply_floor_collision(collision)
	player.state_grounded.transition_land_from_air(player)
	
	
func exit_wall(player, wall_sensor):
	var info = wall_sensor.get_collision_info()
	if info.distance < 0:
		player.position += info.distance * wall_sensor.direction_vec
		if player.velocity.dot(wall_sensor.direction_vec) > 0:
			var h = wall_sensor.direction & 1
			player.velocity.x *= h
			player.velocity.y *= (h^1)
	
	
func get_active_sensors(player):
	var pose = player.pose
	if abs(player.velocity.x) > abs(player.velocity.y):
		return {
			wall_sensors = [pose.right_sensor if player.velocity.x > 0 else pose.left_sensor],
			foot_sensors = pose.foot_sensors
		}
	else:
		return {
			wall_sensors = [pose.right_sensor,  pose.left_sensor],
			foot_sensors = pose.foot_sensors if player.velocity.y > 0 else []
		}


func animate_player(player):
	if rolling:
		player.animate_rolling()
	else:
		player.animate_walking()

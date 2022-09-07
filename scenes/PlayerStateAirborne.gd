extends "res://scenes/PlayerState.gd"

var rolling: bool
var jumping: bool = false

func enter_state(player):
	if rolling:
		player.pose = player.pose_ball
	else:
		player.pose = player.pose_stand
		
	player.pose.direction = 0
		
	player.emit_signal("became_airborne")


func update_player(player, tile_map, tile_meta_array):
	if jumping && !player.jump_pressed && player.velocity.y < -4:
		player.velocity.y = -4
		
	player.velocity.x += 24/256.0 * player.input_h
	
	if -4 < player.velocity.y && player.velocity.y < 0:
		player.velocity.x -= player.velocity.x / 32.0
		
	player.position += player.velocity
	
	player.velocity.y += 56 / 256.0
	
	var active_sensors = get_active_sensors(player)
	for wall_sensor in active_sensors.wall_sensors:
		exit_wall(player, wall_sensor, tile_map, tile_meta_array)
		
	interpolate_angle(player)
	land_on_ground(player, active_sensors.foot_sensors, tile_map, tile_meta_array)
	
	
func interpolate_angle(player):
	if 2 < player.angle && player.angle < 256 - 2:
		player.angle += 2 * sign(player.angle - 128)
	else:
		player.angle = 0
	
func land_on_ground(player, foot_sensors, tile_map, tile_meta_array):
	var movement_direction = player.get_movement_direction()
	var downwards_distance_threshold = -(player.velocity.y + 8)
	
	var collision = null
	var downwards_distance_met = false
	
	for sensor in foot_sensors:
		var cur = sensor.get_collision_info(tile_map, tile_meta_array)
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
	
	
func exit_wall(player, wall_sensor, tile_map, tile_meta_array):
	var info = wall_sensor.get_collision_info(tile_map, tile_meta_array)
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

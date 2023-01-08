extends "res://scenes/entities/player/PlayerState.gd"

const Player = preload("res://scenes/entities/player/Player.gd")

func enter_state(player):
	player.pose.direction = Direction.RIGHT
	player.set_grounded(false)
	player.leave_stood_object()


func interpolate_angle(player):
	if 2 < player.angle && player.angle < 256 - 2:
		player.angle += -2 if player.angle < 128 else 2
	else:
		player.angle = 0


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
		return true
	else:
		return false
		

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


func update_facing_direction_airborne(player):
	if player.input_h != 0:
		player.facing_direction = player.input_h
		

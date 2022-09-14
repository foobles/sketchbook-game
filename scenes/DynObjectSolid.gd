extends Node2D

export(PoolIntArray) var slope_array

const TOP_STICK_RADIUS = 4

onready var hitbox = $Hitbox


func tick_player_interaction(player):
	var initial_hb_pos = hitbox.global_position.floor()
	adjust_hitbox_height(player)
	var hb_delta = hitbox.global_position.floor() - initial_hb_pos
	
	if player.stood_object == self:
		if check_player_on_self(player):
			player.position += hb_delta
	else:
		eject_player(player)


func adjust_hitbox_height(player):
	var x_diff = int(global_position.x) - int(player.global_position.x)
	var idx = (x_diff + len(slope_array)) / 2
	if 0 <= idx && idx < len(slope_array):
		hitbox.position.y = hitbox.height_radius - slope_array[idx]
		

func check_player_on_self(player):
	var pl_hb = player.pose.hitbox
	var pl_pos = pl_hb.global_position.floor() 
	
	var obj_hb = hitbox
	var obj_pos = obj_hb.global_position.floor()
	
	var combined_width_radius = obj_hb.width_radius + pl_hb.width_radius + 1
	var combined_width_diameter = 2*combined_width_radius
	var left_distance = pl_pos.x - (obj_pos.x - combined_width_radius)
	if left_distance <= 0 || left_distance >= combined_width_diameter:
		player.stood_object = null
		return false
	else:
		return true

	
func eject_player(player):
	var pl_hb = player.pose.hitbox
	var pl_pos = pl_hb.global_position.floor() 
	
	var obj_hb = hitbox
	var obj_pos = obj_hb.global_position.floor()
	
	var combined_width_radius = obj_hb.width_radius + pl_hb.width_radius + 1
	var combined_height_radius = obj_hb.height_radius + pl_hb.height_radius
	
	var combined_width_diameter = 2*combined_width_radius
	var combined_height_diameter = 2*combined_height_radius
	
	var left_difference = pl_pos.x - (obj_pos.x - combined_width_radius)
	var top_difference = (pl_pos.y + TOP_STICK_RADIUS) - (obj_pos.y - combined_height_radius)
	
	if (left_difference < 0 
		|| left_difference > combined_width_diameter
		|| top_difference < 0
		|| top_difference > combined_height_diameter
	):
		return
	
	var x_distance = left_difference if pl_pos.x < obj_pos.x else -(combined_width_diameter - left_difference) 
	var y_distance = top_difference if pl_pos.y < obj_pos.y else -(combined_height_diameter - (top_difference - TOP_STICK_RADIUS))

	var is_collision_horizontal = abs(x_distance) <= abs(y_distance)
	if is_collision_horizontal:
		if abs(y_distance) <= TOP_STICK_RADIUS:
			return
			
		if x_distance != 0 && sign(player.velocity.x) == sign(x_distance):
			player.velocity.x = 0
			player.ground_speed = 0
			
		player.position.x -= x_distance
	else:
		if y_distance < 0:
			if player.velocity.y < 0:
				player.velocity.y = 0
				player.position.y -= y_distance
		else:
			if y_distance >= 16:
				return 
			
			var x_cmp = (obj_pos.x + obj_hb.width_radius) - pl_pos.x 
			var obj_action_width = 1 + 2*obj_hb.width_radius
			if (player.velocity.y >= 0 && obj_action_width >= x_cmp && x_cmp >= 0):
				player.position.y -= (y_distance - TOP_STICK_RADIUS + 1)
				player.state_grounded.transition_land_on_object(player, self)


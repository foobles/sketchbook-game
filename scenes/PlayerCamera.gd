extends Camera2D

const Player = preload("res://scenes/entities/player/Player.gd")

export(int) var box_left
export(int) var box_right
export(int) var box_center_v
export(int) var box_radius_v
export(int) var look_up
export(int) var look_down

enum Mode {
	CENTER,
	BOXED,
}

var _v_mode = Mode.BOXED 

var focus_offset = Vector2.ZERO
var _lag_timer = 0


func track_player(player):
	match player.look_direction:
		-1:
			if focus_offset.y > -look_up:
				focus_offset.y -= 2
		0:
			focus_offset.y -= 2*sign(focus_offset.y)
		+1:
			if focus_offset.y < look_down:
				focus_offset.y += 2
	
	var global_player_pos = get_effective_global_player_pos(player)
	var player_camera_pos = to_local(global_player_pos) - player.position_offset + focus_offset
	
	var camera_motion = Vector2.ZERO
	var speed_cap = Vector2(16, 16)
	
	if player_camera_pos.x < box_left:
		camera_motion.x = -(box_left - player_camera_pos.x)
	elif player_camera_pos.x > box_right:
		camera_motion.x = (player_camera_pos.x - box_right)
		
	match _v_mode:
		Mode.CENTER:
			camera_motion.y = (player_camera_pos.y - box_center_v)
			
			if player.ground_speed < 8:
				speed_cap.y = 6
		
		Mode.BOXED:
			var box_bottom = box_center_v + box_radius_v
			var box_top = box_center_v - box_radius_v
			if player_camera_pos.y < box_top:
				camera_motion.y = -(box_top - player_camera_pos.y)
			elif player_camera_pos.y > box_bottom:
				camera_motion.y = (player_camera_pos.y - box_bottom)
	
	if focus_offset != Vector2.ZERO:
		speed_cap.y = 2
	
	position.x += clamp(camera_motion.x, -speed_cap.x, speed_cap.x)
	position.y += clamp(camera_motion.y, -speed_cap.y, speed_cap.y)
	
	position = position.floor()
	
	
func get_effective_global_player_pos(player):
	if _lag_timer == 0:
		return player.global_position
	else:
		var i = posmod(player.position_arr_idx - _lag_timer, Player.POSITION_ARR_SIZE) 
		_lag_timer -= 1
		return player.position_arr[i]
		
	
func _draw():
	var box_top = box_center_v - box_radius_v
	var box_width = box_right - box_left
	var box_height = 2 * box_radius_v
	
	draw_rect(
		Rect2(box_left, box_top, box_width, box_height),
		Color.white,
		false
	)
	
	draw_line(
		Vector2(box_left, box_center_v), 
		Vector2(box_right, box_center_v),
		Color.green
	)



func _on_Player_became_airborne():
	_v_mode = Mode.BOXED


func _on_Player_became_grounded():
	_v_mode = Mode.CENTER
	
func _on_Player_rev_released(lag):
	_lag_timer = lag

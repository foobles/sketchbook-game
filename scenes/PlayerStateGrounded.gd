extends "res://scenes/PlayerState.gd"

const Player = preload("res://scenes/Player.gd")

onready var _pose_stand = $PoseStand
onready var _pose_ball = $PoseBall
onready var _poses = [$PoseStand, $PoseBall]

var _pose = null

class PoseInfo:
	var pose 
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
	func _init(_pose):
		pose = _pose
		accel = 12 / 256.0 
		decel = 128 / 256.0 
		friction = 12 / 256.0 
		slope_factor = 32 / 256.0
		standing_slope_slip_threshold = 13 / 256.0


	func update_constants(player):
		var wall_sensor_y = 8 if player.angle != 0 else 0
		pose.left_sensor.position.y = wall_sensor_y
		pose.right_sensor.position.y = wall_sensor_y

	
	func animate_player(player):
		player.animate_walking()
		
	
	func transition_inner(player, grounded):
		if player.ground_speed != 0 && player.input_v == 1:
			grounded._set_inner_state(grounded._info_ball)


class PoseInfoBall extends PoseInfo:
	func _init(_pose):
		pose = _pose
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
			grounded._set_inner_state(grounded._info_stand)

var _inner_state: PoseInfo

onready var _info_stand = PoseInfoStand.new(_pose_stand)
onready var _info_ball = PoseInfoBall.new(_pose_ball)

func _set_inner_state(pose_info):
	var old_direction = 0
	if _pose != null:
		old_direction = _pose.direction
		remove_child(_pose)
		
	add_child(pose_info.pose)
	
	_pose = pose_info.pose
	_pose.direction = old_direction
	_inner_state = pose_info
		
		
func _ready():
	for p in _poses:
		remove_child(p)
	
	_set_inner_state(_info_ball)
	
	
func update_player(player, tile_map, tile_meta_array):
	_inner_state.update_constants(player)
	
	apply_slope_factor(player)
	
	if is_accelerating(player):
		apply_acceleration(player)
	elif is_decelerating(player):
		apply_deceleration(player)
	else:
		apply_friction(player)
		
	var angle_rads = player.get_angle_rads()
	player.velocity = player.ground_speed * Vector2(cos(angle_rads), -sin(angle_rads))
	
	_inner_state.transition_inner(player, self)
	
	if _pose.left_sensor.direction_vec.dot(player.velocity) > 0:
		player.prevent_wall_collision(_pose.left_sensor, tile_map, tile_meta_array)
	elif _pose.right_sensor.direction_vec.dot(player.velocity) > 0:
		player.prevent_wall_collision(_pose.right_sensor, tile_map, tile_meta_array)
	
	player.position += player.velocity
	if player.snap_to_floor(_pose.foot_sensors, tile_map, tile_meta_array) != null:
		_pose.set_direction(player.get_current_direction())
	

func apply_slope_factor(player):
	var angle_rads = player.get_angle_rads()
	var slope_accel = _inner_state.slope_factor * sin(angle_rads)
	if player.ground_speed != 0 || abs(slope_accel) >= _inner_state.standing_slope_slip_threshold:
		player.ground_speed -= slope_accel


func is_accelerating(player):
	var walk_accel = _inner_state.accel
	return (
		walk_accel != null
		&& player.input_h != 0
		&& player.input_h != -sign(player.ground_speed)
	)


func is_decelerating(player):
	var walk_decel = _inner_state.decel
	return (
		walk_decel != null
		&& player.input_h != 0
		&& player.input_h == -sign(player.ground_speed)
	)


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
	if player.ground_speed != 0:
		player.sprite.flip_h = (sign(player.ground_speed) == -1)
		
	_inner_state.animate_player(player)
	
extends "res://scenes/PlayerState.gd"

var rolling: bool setget set_rolling
var jumping: bool = false

onready var _pose_stand = $PoseStand
onready var _pose_ball = $PoseBall

var _pose

func set_rolling(r):
	rolling = r
	if _pose != null:
		remove_child(_pose)
	
	if r:
		_pose = _pose_ball
	else:
		_pose = _pose_stand
		
	add_child(_pose)
	

func _ready():
	remove_child(_pose_stand)
	remove_child(_pose_ball)


func update_player(player, tile_set, tile_meta_array):
	if jumping && !Input.is_action_pressed("control_jump") && player.velocity.y < -4:
		player.velocity.y = -4
		
	player.velocity.x += 24/256.0 * player.input_h
	
	if -4 < player.velocity.y && player.velocity.y < 0:
		player.velocity.x -= player.velocity.x / 32.0
		
	player.position += player.velocity
	
	player.velocity.y += 56 / 256.0
	
	var active_sensors = get_active_sensors(player)
	for wall_sensor in active_sensors.wall_sensors:
		player.prevent_wall_collision(wall_sensor, tile_set, tile_meta_array)
		
	if player.snap_to_floor(active_sensors.foot_sensors, tile_set, tile_meta_array) != null:
		player.set_state(player.state_grounded)
	
	
	
func get_active_sensors(player):
	if abs(player.velocity.x) > abs(player.velocity.y):
		return {
			wall_sensors = [_pose.right_sensor if player.velocity.x > 0 else _pose.left_sensor],
			foot_sensors = _pose.foot_sensors
		}
	else:
		return {
			wall_sensors = [_pose.right_sensor,  _pose.left_sensor],
			foot_sensors = _pose.foot_sensors if player.velocity.y > 0 else []
		}


func animate_player(player):
	if rolling:
		player.animate_rolling()
	else:
		player.animate_walking()
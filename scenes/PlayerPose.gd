extends Node2D

onready var left_sensor = $WallLeft
onready var right_sensor = $WallRight
onready var foot_sensors = [$FootLeft, $FootRight]

var idle_anim: String
var walk_anim: String
var run_anim: String

var walk_accel
var walk_decel
var walk_friction
var slope_factor
var max_walk_speed
var standing_slope_slip_threshold


func get_foot_direction_vec():
	return foot_sensors[0].direction_vec


#warning-ignore:unused_argument
func update_constants(player):
	pass

func update_direction(player):
	var dir = player.get_current_direction()
	rotation_degrees = -dir * 90
	for sensor in get_children():
		sensor.set_direction_rotation(dir)

extends Node2D

onready var left_sensor = $WallLeft
onready var right_sensor = $WallRight
onready var foot_sensors = [$FootLeft, $FootRight]

var walk_accel: float
var walk_decel: float
var walk_friction: float
var slope_factor: float
var max_walk_speed: float
var standing_slope_slip_threshold:float


func get_foot_direction_vec():
	return foot_sensors[0].direction_vec

func update_direction(player):
	var dir = player.get_current_direction()
	rotation_degrees = -dir * 90
	for sensor in get_children():
		sensor.set_direction_rotation(dir)

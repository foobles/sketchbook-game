extends Node2D

onready var left_sensor = $WallLeft
onready var right_sensor = $WallRight
onready var foot_sensors = [$FootLeft, $FootRight]

var direction = 0 setget set_direction

func set_direction(dir):
	direction = dir
	rotation_degrees = -90 * dir
	for sensor in get_children():
		sensor.set_direction_rotation(dir)

func get_foot_direction_vec():
	return foot_sensors[0].direction_vec

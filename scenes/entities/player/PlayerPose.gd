extends Node2D

export(Vector2) var offset = Vector2(0, 0)

onready var left_sensor = $WallLeft
onready var right_sensor = $WallRight
onready var left_foot_sensor = $FootLeft
onready var right_foot_sensor = $FootRight
onready var foot_sensors = [left_foot_sensor, right_foot_sensor]

var direction = 0 setget set_direction

func set_direction(dir):
	direction = dir
	rotation_degrees = -90 * dir
	for sensor in get_children():
		sensor.set_direction_rotation(dir)

func get_foot_direction_vec():
	return foot_sensors[0].direction_vec

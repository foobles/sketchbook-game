extends "res://scenes/PlayerPose.gd"


func _init():
	idle_anim = "idle"
	walk_anim = "walk"
	run_anim = "run"
	
	walk_accel = 12 / 256.0
	walk_decel = 128 / 256.0
	walk_friction = 12 / 256.0
	slope_factor = 32 / 256.0
	max_walk_speed = 6.0
	standing_slope_slip_threshold = 13 / 256.0


func update_direction(player):
	.update_direction(player)
	var wall_sensor_y = 0 if player.angle != 0 else 8
	left_sensor.position.y = wall_sensor_y
	right_sensor.position.y = wall_sensor_y 

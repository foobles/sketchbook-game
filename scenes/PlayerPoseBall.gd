extends "res://scenes/PlayerPose.gd"

const _ROLL_UP_SLOPE_FACTOR = 20 / 256.0
const _ROLL_DOWN_SLOPE_FACTOR = 80 / 256.0

func _init():
	idle_anim = "idle"
	walk_anim = "roll"
	run_anim = "roll_fast"
	
	walk_accel = null
	walk_decel = 32 / 256.0
	walk_friction = 6 / 256.0
	max_walk_speed = 6.0
	standing_slope_slip_threshold = 0.0


func update_constants(player):
	if (player.ground_speed > 0) == (player.angle < 128):
		slope_factor = _ROLL_UP_SLOPE_FACTOR
	else:
		slope_factor = _ROLL_DOWN_SLOPE_FACTOR

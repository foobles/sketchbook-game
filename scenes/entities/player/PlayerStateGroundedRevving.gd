extends "res://scenes/entities/player/PlayerStateGrounded.gd"

var revs = 0
const AIRBORNE_MODE = AirborneNormal.MODE_REVVING

func enter_state(player):
	.enter_state(player)
	player.set_dimensions(Player.STAND_DIMENSIONS)
	player.is_rolling = true
	player.ground_speed = 0
	player.velocity = Vector2.ZERO
	revs = 0
	
func update_player(player):
	if player.jump_just_pressed:
		revs = min(revs + 2, 8)
	
	revs -= floor(revs / 0.125) / 256
	
	if player.stood_object == null:
		snap_to_floor(player)
		
	if player.input_v != 1:
		player.ground_speed = player.facing_direction * (8 + floor(revs) / 2)
		player.set_state(player.state_grounded_rolling)
		player.emit_signal("rev_released", 32 - floor(revs))
		
func animate_player(player):
	player.animate_revving()
	if player.jump_just_pressed:
		player.restart_animation()

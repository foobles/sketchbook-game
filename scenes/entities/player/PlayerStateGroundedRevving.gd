extends "res://scenes/entities/player/PlayerStateGrounded.gd"

var revs = 0
const AIRBORNE_STATE = Airborne.MODE_REVVING

func enter_state(player):
	.enter_state(player)
	player.set_dimensions(Player.STAND_DIMENSIONS)
	player.ground_speed = 0
	player.velocity = Vector2.ZERO
	revs = 0
	
func update_player(player):
	if player.jump_just_pressed:
		revs = min(revs + 2, 8)
	
	revs -= floor(revs / 0.125) / 256
		
	snap_to_floor(player, AIRBORNE_STATE)
		
	if player.input_v != 1:
		player.ground_speed = player.direction * (8 + floor(revs) / 2)
		player.set_state(player.state_grounded_rolling)
		
		
func animate_player(player):
	player.animate_revving()
	if player.jump_just_pressed:
		player.restart_animation()

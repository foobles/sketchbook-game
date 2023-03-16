extends Node

const DEATH_JUMP_VELOCITY = -7
const DEATH_JUMP_GRAVITY = 56 / 256.0

func enter_state(player):
	player.emit_signal("died")
	player.angle = 0
	player.invul_frames = 0
	player.velocity = Vector2(0, DEATH_JUMP_VELOCITY)


func update_player(player):
	player.position += player.velocity
	player.velocity.y += DEATH_JUMP_GRAVITY
	
	
func animate_player(player):
	player.animate_dead()

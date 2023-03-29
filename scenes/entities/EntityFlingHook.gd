tool
extends "res://scenes/entities/Entity.gd"

onready var grab_position = $Hitbox/GrabPosition
export(int, 12, 2048) var extension_length = 12 setget set_extension_length

const HOOK_RETRACTED_Y = 12

var hook_accel = 32.0 / 60
var hook_velocity = 0
var hook_max_velocity = 10
var state = STATE_IDLING

var hook_extend_velocity = 2

enum {
	STATE_RETRACTING
	STATE_IDLING
	STATE_EXTENDING
}

func _ready():
	$HookSprite.position = $Hitbox.position
	

func tick_player_interaction(player):
	if hook_velocity == 0:
		$AnimationPlayer.stop()
	else:
		$AnimationPlayer.playback_speed = -4*hook_velocity
		
	match state:
		STATE_IDLING:
			hook_velocity += hook_accel / 4
			if hitbox.position.y == extension_length:
				check_grab(player)
			else:
				if hook_velocity > 0:
					hook_velocity = hook_extend_velocity
					state = STATE_EXTENDING
				
			
		STATE_RETRACTING:
			hook_velocity = max(-hook_max_velocity, hook_velocity - hook_accel)
			hitbox.position.y += hook_velocity
			if player.puppeteer == self:
				player.global_position = grab_position.global_position
				if hitbox.position.y <= HOOK_RETRACTED_Y:
					transition_player_fling_hook_release(player)
				elif player.jump_just_pressed:
					transition_player_fling_hook_jump(player)
			
			if hitbox.position.y <= HOOK_RETRACTED_Y:
				hitbox.position.y = HOOK_RETRACTED_Y
				state = STATE_IDLING
				
		STATE_EXTENDING:
			hitbox.position.y += hook_velocity
			if hitbox.position.y >= extension_length:
				hitbox.position.y = extension_length
				hook_velocity = 0
				state = STATE_IDLING
			check_grab(player)
			
	$HookSprite.position = hitbox.position


func check_grab(player):
	if (player.puppeteer != self
		&& !player.is_grounded 
		&& player.global_position.y >= hitbox.global_position.y 
		&& player.velocity.y > 0
		&& hitbox.collides_with(player.hitbox)
	):
		player.puppeteer = self
		player.global_position = grab_position.global_position
		player.animate_hanging()
		hook_velocity = 2
		state = STATE_RETRACTING
		$AnimationPlayer.play("rotate")
		

func set_extension_length(new_extension_length):
	extension_length = new_extension_length
	if Engine.editor_hint:
		$Hitbox.position.y = new_extension_length
		var spr = get_node_or_null("HookSprite")
		if spr != null:
			spr.position = $Hitbox.position


func transition_player_fling_hook_jump(player):
	player.puppeteer = null 
	var airborne = player.state_airborne_normal
	airborne.mode = airborne.MODE_ROLLING 
	airborne.jumping = true
	player.velocity = Vector2(player.input_h, hook_velocity * 0.75 - 4)
	player.set_state(airborne)
	
	
func transition_player_fling_hook_release(player):
	player.puppeteer = null 
	var airborne = player.state_airborne_normal
	airborne.mode = airborne.MODE_UPRIGHT 
	airborne.jumping = false
	player.velocity = Vector2(0, hook_velocity * 0.75)
	player.set_state(airborne)

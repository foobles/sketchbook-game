tool
extends "res://scenes/entities/EntitySolid.gd"

const PULL_IN_DISTANCE = 8
const CONTROL_LOCK_FRAMES = 16

enum Power {
	STRONG,
	WEAK
}

export(int, "right", "up", "left", "down") var push_direction = Direction.UP setget set_push_direction 
export(Power) var push_power = Power.STRONG setget set_push_power

const _HB_WIDTH = 15
const _HB_HEIGHT = 8

func _ready():
	match push_direction:
		Direction.RIGHT, Direction.LEFT:
			self.connect("player_collided_horizontal", self, "trigger_push")
		Direction.DOWN:
			self.connect("player_collided_bottom", self, "trigger_push")
		Direction.UP:
			self.connect("player_landed_top", self, "trigger_push")
			

func trigger_push(player):
	var push_speed = get_push_speed()
	
	if player.is_grounded && push_direction & 1 == 0:
		player.control_lock = CONTROL_LOCK_FRAMES
	player.transition_become_airborne()
	match push_direction:
		Direction.RIGHT:
			player.velocity.x = push_speed
			player.position.x -= PULL_IN_DISTANCE
			player.facing_direction = +1
			
		Direction.UP:
			player.velocity.y = -push_speed
			player.position.y += PULL_IN_DISTANCE
			
		Direction.LEFT:
			player.velocity.x = -push_speed
			player.position.x += PULL_IN_DISTANCE
			player.facing_direction = -1
			
		Direction.DOWN:
			player.velocity.y = push_speed
			player.position.y -= PULL_IN_DISTANCE
	
	match push_power:
		Power.WEAK: $AnimationPlayer.play("trigger_weak")
		Power.STRONG: $AnimationPlayer.play("trigger_strong")


func set_push_direction(new_push_direction):
	push_direction = new_push_direction
	$Sprite.rotation_degrees = -90 * (push_direction-1)
	if push_direction & 1 == 1:
		$Hitbox.radius = Vector2(_HB_WIDTH, _HB_HEIGHT)
	else:
		$Hitbox.radius = Vector2(_HB_HEIGHT, _HB_WIDTH)


func set_push_power(new_push_power):
	push_power = new_push_power
	$Sprite.frame = push_power * 3
	
	
func get_push_speed():
	match push_power:
		Power.WEAK: return 10
		Power.STRONG: return 16

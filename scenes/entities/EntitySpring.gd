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
	var push_vec = Direction.to_vec(push_direction)
	player.position -= push_vec * PULL_IN_DISTANCE
	
	var directions_aligned = (player.pose.direction ^ push_direction) & 1 == 0
	if player.is_grounded && directions_aligned:
		player.ground_speed = get_push_speed()
		if player.pose.direction != push_direction:
			player.ground_speed *= -1
		
		player.facing_direction = sign(player.ground_speed)
		player.control_lock = CONTROL_LOCK_FRAMES
	else:
		player.transition_become_airborne()
		var perp_v = player.velocity.cross(push_vec) * Vector2(push_vec.y, -push_vec.x)
		var push_v = get_push_speed() * push_vec
		player.velocity = perp_v + push_v
		player.control_lock = 0
	
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

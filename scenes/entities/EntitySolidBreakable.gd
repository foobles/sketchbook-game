extends "res://scenes/entities/EntitySolid.gd"

onready var destruction_hitbox = $DestructionHitbox
onready var fall_sensor = $FallSensor

const GRAVITY = 56 / 256.0
const BUMP_VELOCITY = -1.5

var falling = false
var y_velocity = 0

func _ready():
	destruction_hitbox.radius = hitbox.radius - Vector2(1, 1)
	fall_sensor.position.y = hitbox.radius.y

func tick():
	if falling:
		y_velocity += GRAVITY
		position.y += y_velocity
		
		var collision = fall_sensor.get_collision_info()
		if collision.distance < 0:
			position.y += collision.distance
			falling = false


func tick_player_interaction(player):
	if destruction_hitbox.collides_with(player.hitbox):
		if player.velocity.y >= 0:
			if player.is_rolling:
				player.velocity.y *= -1
				self.on_destroyed(player)
		else: 
			if player.global_position.y >= global_position.y + hitbox.radius.y:
				player.velocity.y *= -1
				self.y_velocity = BUMP_VELOCITY
				falling = true
			
	.tick_player_interaction(player)


func eject_player(player):
	if !player.is_rolling || player.velocity.y < 0:
		.eject_player(player)
	

const EntityParticleExplosion = preload("res://scenes/entities/EntityParticleExplosion.tscn")
func on_destroyed(_player):
	var explosion = EntityParticleExplosion.instance()
	get_parent().add_child(explosion)
	explosion.position = position
	queue_free()

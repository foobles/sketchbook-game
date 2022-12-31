extends "res://scenes/entities/player/PlayerStateAirborne.gd"

const HURT_BUMP_SPEED_Y = 4
const HURT_BUMP_SPEED_X = 2
const HURT_GRAVITY = 48 / 256.0
const RECOVERY_INVUL_FRAMES = 120

func enter_state(player):
	.enter_state(player)
	player.set_dimensions(Player.BALL_DIMENSIONS)
	player.is_rolling = false


func update_player(player):
	player.invul_frames = RECOVERY_INVUL_FRAMES
	player.position += player.velocity
	player.velocity.y += HURT_GRAVITY
	var active_sensors = get_active_sensors(player)
	for wall_sensor in active_sensors.wall_sensors:
		exit_wall(player, wall_sensor)
		
	interpolate_angle(player)
	if land_on_surface(player, active_sensors.foot_sensors, +1) && player.velocity.y > 0:
		player.state_grounded_upright.transition_land_from_air_floor(player)
	if land_on_surface(player, active_sensors.head_sensors, -1):
		player.velocity.y = 0


func animate_player(player):
	player.animate_hurt()

func transition_damage(player, damage_source_x):
	var player_left_of_source = player.position.x < damage_source_x
	player.velocity.x = -HURT_BUMP_SPEED_X if player_left_of_source else +HURT_BUMP_SPEED_X
	player.velocity.y = -HURT_BUMP_SPEED_Y
	player.set_state(self)

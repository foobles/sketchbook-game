extends "res://scenes/entities/Entity.gd"

const RUN_SPEED = 6.0

var ground_speed: float = 0.0
var angle: int = 0
var velocity: Vector2 = Vector2()

var facing_direction: int = 1
var input_h = 0
var input_v = 0

var jump_pressed = false
var jump_just_pressed = false

var control_lock = 0
var invul_frames = 0
var stood_object = null
var puppeteer = null
var look_direction = 0

# warning-ignore:unused_signal
signal became_airborne
# warning-ignore:unused_signal
signal became_grounded
# warning-ignore:unused_signal
signal rev_released
# warning-ignore:unused_signal
signal died
signal respawned

var is_grounded 
var is_rolling

export var roll_enabled = false
export var rev_enabled = false
export var wall_jump_enabled = false

onready var respawn_pos = position

onready var state_grounded_upright = $StateGroundedUpright
onready var state_grounded_rolling = $StateGroundedRolling
onready var state_grounded_revving = $StateGroundedRevving
onready var state_airborne_normal = $StateAirborneNormal
onready var state_airborne_hurt = $StateAirborneHurt
onready var state_dead = $StateDead
onready var _state = state_grounded_upright
onready var pose = $Pose

const POSITION_ARR_SIZE = 120
var position_arr_idx = 0
var position_arr = PoolVector2Array()

var push_radius: int = 10
var radius: Vector2
var position_offset: Vector2 

const STAND_DIMENSIONS = {
	radius = Vector2(9, 19),
	offset = Vector2(0, 0)
}

const BALL_DIMENSIONS = {
	radius = Vector2(7, 14),
	offset = Vector2(0, 5)
}

func read_input():
	input_h = \
		int(Input.is_action_pressed("control_move_right")) \
		- int(Input.is_action_pressed("control_move_left"))
		
	input_v = \
		int(Input.is_action_pressed("control_move_down")) \
		- int(Input.is_action_pressed("control_move_up"))
		
	
	var prev_jump_pressed = jump_pressed
	jump_pressed = Input.is_action_pressed("control_jump") 
	jump_just_pressed = jump_pressed && !prev_jump_pressed
	
	if is_grounded && is_control_locked():
		input_h = 0
		
	
func update_position_array():
	position_arr_idx = (position_arr_idx + 1) % POSITION_ARR_SIZE
	position_arr[position_arr_idx] = global_position - position_offset
	
	
func _ready():
	set_dimensions(STAND_DIMENSIONS)
	pose.left_sensor.position.x = -push_radius
	pose.right_sensor.position.x = push_radius
	position_arr.resize(POSITION_ARR_SIZE)
	
	
func set_state(new_state):
	new_state.enter_state(self)
	_state = new_state
	
	
func set_dimensions(dimensions):
	radius = dimensions.radius
	
	position += (dimensions.offset - position_offset)
	position_offset = dimensions.offset
	
	pose.left_foot_sensor.position = Vector2(-radius.x, radius.y)
	pose.right_foot_sensor.position = Vector2(radius.x, radius.y)
	
	pose.left_head_sensor.position = Vector2(-radius.x, -radius.y) 
	pose.right_head_sensor.position = Vector2(radius.x, -radius.y)
	
	hitbox.radius.y = radius.y - 3


func set_animation(anim):
	if $AnimationPlayer.current_animation != anim:
		$AnimationPlayer.play(anim)


func set_animation_ticks(n):
	$AnimationPlayer.playback_speed = 60.0 / (n + 1)
	
func set_animation_reversed(r):
	var abs_speed = abs($AnimationPlayer.playback_speed)
	$AnimationPlayer.playback_speed = abs_speed * (-1 if r else 1)
	
func restart_animation():
	$AnimationPlayer.seek(0)


func is_control_locked():
	return control_lock > 0

const _OCT = 32
func get_current_direction():
	if angle <= _OCT || angle >= 7*_OCT:
		return Direction.RIGHT
	elif 3*_OCT <= angle && angle <= 5*_OCT:
		return Direction.LEFT
	elif _OCT < angle && angle < 3*_OCT:
		return Direction.UP
	else:
		return Direction.DOWN


func get_movement_direction():
	if abs(velocity.x) > abs(velocity.y):
		return Direction.RIGHT if velocity.x > 0 else Direction.LEFT
	else:
		return Direction.UP if velocity.y < 0 else Direction.DOWN
		

func get_angle_rads():
	return float(angle) / 128.0 * PI


func tick():
	read_input()
	update_invul_frames()
	if puppeteer == null:
		_state.update_player(self)
		_state.animate_player(self)
	sprite.global_position = global_position.floor()
	if facing_direction == 1:
		sprite.global_position.x += 1


func apply_floor_collision(collision):
	position += collision.distance * collision.sensor.direction_vec
	if collision.angle != 255:
		angle = collision.angle
	else:
		angle = get_current_direction() * 64


func inflict_damage(source):
	if invul_frames == 0:
		state_airborne_hurt.transition_damage(self, source.position.x)
	
	
func force_inflict_damage(source):
	if invul_frames == 0:
		state_airborne_hurt.transition_damage(self, source.position.x)
	else:
		kill()
	
func kill():
	set_state(state_dead)
	

func respawn():
	state_airborne_normal.transition_no_floor(self, state_airborne_normal.MODE_UPRIGHT)
	velocity = Vector2.ZERO
	position = respawn_pos
	emit_signal("respawned")
	
	
func is_below(global_threshold_y):
	return global_position.y - radius.y > global_threshold_y
	
	
func update_invul_frames():
	if invul_frames > 0:
		invul_frames -= 1
		# using position_arr_idx is a bit of a hack but it works for now
		sprite.visible = (position_arr_idx & 4 == 0)
	else:
		sprite.visible = true
		
		
func transition_land_on_object(object):
	velocity.y = 0
	if pose.direction == Direction.RIGHT:
		stood_object = object
		ground_speed = velocity.x
		angle = 0
		set_state(state_grounded_upright)
	else:
		ground_speed = 0


func transition_become_airborne():
	_state.become_airborne(self)


func animate_rolling():
	if abs(ground_speed) < RUN_SPEED:
		set_animation("roll")
	else:
		set_animation("roll_fast")
	set_animation_ticks(max(0, floor(4 - abs(ground_speed))))
	sprite.rotation = 0


func animate_walking():
	var oct = ((angle + 48) & 0xFF) >> 5 
	if oct & 1:
		if abs(ground_speed) < RUN_SPEED: 
			set_animation("walk")
		else:
			set_animation("run")
	else:
		oct += facing_direction - 1
		if abs(ground_speed) < RUN_SPEED: 
			set_animation("walk_diagonal")
		else:
			set_animation("run_diagonal")
		
	set_animation_ticks(max(0, floor(8 - abs(ground_speed))))
	sprite.rotation_degrees = -(oct >> 1) * 90

	
func animate_standing():
	set_animation("idle")
	sprite.rotation = 0
	
func animate_hanging():
	set_animation("hang")
	sprite.rotation = 0
	
func animate_look_up():
	set_animation("look_up")
	sprite.rotation = 0
	
func animate_look_down():
	set_animation("look_down")
	sprite.rotation = 0

func animate_revving():
	set_animation("rev")
	set_animation_ticks(0)
	sprite.rotation = 0

func animate_pushing():
	set_animation("push")
	set_animation_ticks(30)
	sprite.rotation = 0
	
func animate_skidding():
	set_animation("skid")
	set_animation_ticks(8)
	sprite.rotation = 0
	
func animate_hurt():
	set_animation("hurt")
	set_animation_ticks(8)
	sprite.rotation = 0
	
	
func animate_dead():
	set_animation("die")
	sprite.rotation = 0


func set_grounded(g):
	if g != is_grounded:
		if g:
			emit_signal("became_grounded")
		else:
			emit_signal("became_airborne")
			
	is_grounded = g


func leave_stood_object():
	if stood_object != null:
		stood_object.unground_player(self)

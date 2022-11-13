extends "res://scenes/entities/Entity.gd"

const RUN_SPEED = 6.0

var ground_speed: float = 0.0
var angle: int = 0
var velocity: Vector2 = Vector2()

var direction: int = 1
var input_h = 0
var input_v = 0

var jump_pressed = false
var jump_just_pressed = false

var control_lock = 0
var stood_object = null
var look_direction = 0

# warning-ignore:unused_signal
signal became_airborne
# warning-ignore:unused_signal
signal became_grounded
# warning-ignore:unused_signal
signal rev_released

var is_grounded 
var is_rolling

onready var state_grounded_upright = $StateGroundedUpright
onready var state_grounded_rolling = $StateGroundedRolling
onready var state_grounded_revving = $StateGroundedRevving
onready var state_airborne = $StateAirborne
onready var _state = state_grounded_revving
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
		
	if input_h != 0:
		direction = input_h
		
	input_v = \
		int(Input.is_action_pressed("control_move_down")) \
		- int(Input.is_action_pressed("control_move_up"))
		
	
	var prev_jump_pressed = jump_pressed
	jump_pressed = Input.is_action_pressed("control_jump") 
	jump_just_pressed = jump_pressed && !prev_jump_pressed
	
	
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
		return 0
	elif 3*_OCT <= angle && angle <= 5*_OCT:
		return 2
	elif _OCT < angle && angle < 3*_OCT:
		return 1
	else:
		return 3


func get_movement_direction():
	if abs(velocity.x) > abs(velocity.y):
		return 0 if velocity.x > 0 else 2
	else:
		return 1 if velocity.y < 0 else 3
		

func get_angle_rads():
	return float(angle) / 128.0 * PI


func tick():
	read_input()
	position_arr[position_arr_idx] = global_position
	position_arr_idx = (position_arr_idx + 1) % POSITION_ARR_SIZE
	_state.update_player(self)
	_state.animate_player(self)
	sprite.global_position = global_position.floor()


func apply_floor_collision(collision):
	position += collision.distance * collision.sensor.direction_vec
	if collision.angle != 255:
		angle = collision.angle
	else:
		angle = get_current_direction() * 64

	
func transition_land_on_object(object):
	stood_object = object
	velocity.y = 0
	ground_speed = velocity.x
	angle = 0
	set_state(state_grounded_upright)


func animate_rolling():
	if abs(ground_speed) < RUN_SPEED:
		set_animation("roll")
	else:
		set_animation("roll_fast")
	set_animation_ticks(max(0, floor(4 - abs(ground_speed))))
	sprite.rotation = 0


func animate_walking():
	if abs(ground_speed) < RUN_SPEED:
		set_animation("walk")
	else:
		set_animation("run")
	set_animation_ticks(max(0, floor(8 - abs(ground_speed))))
	sprite.rotation = -stepify(get_angle_rads(), PI / 4)
	
func animate_standing():
	set_animation("idle")
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

func set_grounded(g):
	if g != is_grounded:
		if g:
			emit_signal("became_grounded")
		else:
			emit_signal("became_airborne")
			
	is_grounded = g

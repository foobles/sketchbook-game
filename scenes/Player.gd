extends Node2D

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

# warning-ignore:unused_signal
signal became_airborne
# warning-ignore:unused_signal
signal became_grounded


onready var sprite = $Sprite

onready var state_grounded = $StateGrounded
onready var state_airborne = $StateAirborne
onready var _states = [state_grounded, state_airborne]
onready var _state = state_grounded

onready var pose = $Pose
onready var hitbox = $Hitbox

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
	for s in _states:
		if s != _state:
			remove_child(s)
			
	set_dimensions(STAND_DIMENSIONS)
	pose.left_sensor.position.x = -push_radius
	pose.right_sensor.position.x = push_radius
	
	
func set_state(new_state):
	remove_child(_state)
	add_child(new_state)
	new_state.enter_state(self)
	_state = new_state
	
	
func set_dimensions(dimensions):
	radius = dimensions.radius
	
	position += (dimensions.offset - position_offset)
	position_offset = dimensions.offset
	
	pose.left_foot_sensor.position = Vector2(-radius.x, radius.y)
	pose.right_foot_sensor.position = Vector2(radius.x, radius.y)
	hitbox.radius.y = radius.y - 3


func set_animation(anim):
	if $AnimationPlayer.current_animation != anim:
		$AnimationPlayer.play(anim)


func set_animation_ticks(n):
	$AnimationPlayer.playback_speed = 60.0 / (n + 1)
	
func set_animation_reversed(r):
	var abs_speed = abs($AnimationPlayer.playback_speed)
	$AnimationPlayer.playback_speed = abs_speed * (-1 if r else 1)

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
	_state.update_player(self)
	_state.animate_player(self)
	sprite.global_position = global_position.floor()


func apply_floor_collision(collision):
	position += collision.distance * collision.sensor.direction_vec
	if collision.angle != 255:
		angle = collision.angle
	else:
		angle = get_current_direction() * 64


func animate_rolling():
	if abs(ground_speed) < RUN_SPEED:
		set_animation("roll")
	else:
		set_animation("roll_fast")
	set_animation_ticks(max(0, floor(4 - abs(ground_speed))))
	sprite.rotation = 0


func animate_walking():
	if ground_speed == 0:
		set_animation("idle")
		set_animation_ticks(60)
	else:
		if abs(ground_speed) < RUN_SPEED:
			set_animation("walk")
		else:
			set_animation("run")
		set_animation_ticks(max(0, floor(8 - abs(ground_speed))))
		
	sprite.rotation = -stepify(get_angle_rads(), PI / 4)

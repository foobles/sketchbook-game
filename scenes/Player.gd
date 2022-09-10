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

# warning-ignore:unused_signal
signal became_airborne
# warning-ignore:unused_signal
signal became_grounded


onready var sprite = $Sprite

onready var state_grounded = $StateGrounded
onready var state_airborne = $StateAirborne
onready var _states = [state_grounded, state_airborne]
onready var _state = state_grounded

onready var pose_ball = $PoseBall
onready var pose_stand = $PoseStand
onready var pose = pose_stand setget set_pose
onready var _poses = [pose_ball, pose_stand]


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
			
	for p in _poses:
		if p != pose:
			remove_child(p)
			
		
func set_state(new_state):
	remove_child(_state)
	add_child(new_state)
	new_state.enter_state(self)
	_state = new_state
	
	
func set_pose(new_pose):
	remove_child(pose)
	add_child(new_pose)
	pose = new_pose


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


func tick(tile_map, tile_meta_array):
	read_input()
	_state.update_player(self, tile_map, tile_meta_array)
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


const TOP_STICK_RADIUS = 4

func eject_from_hitbox(obj_hb):
	
	var pl_hb = pose.hitbox
	var pl_pos = pl_hb.global_position.floor() 
	
	var obj_pos = obj_hb.global_position.floor()
	
	var combined_width_radius = obj_hb.width_radius + pl_hb.width_radius + 1
	var combined_height_radius = obj_hb.height_radius + pl_hb.height_radius
	
	var combined_width_diameter = 2*combined_width_radius
	var combined_height_diameter = 2*combined_height_radius
	
	var left_difference = pl_pos.x - (obj_pos.x - combined_width_radius)
	var top_difference = (pl_pos.y + TOP_STICK_RADIUS) - (obj_pos.y - combined_height_radius)
	
	if (left_difference < 0 
		|| left_difference > combined_width_diameter
		|| top_difference < 0
		|| top_difference > combined_height_diameter
	):
		return
		
	var x_distance = left_difference if pl_pos.x < obj_pos.x else -(combined_width_diameter - left_difference) 
	var y_distance = top_difference if pl_pos.y < obj_pos.y else -(combined_height_diameter - (top_difference - TOP_STICK_RADIUS))

	var is_collision_horizontal = abs(x_distance) <= abs(y_distance)
	if is_collision_horizontal:
		if abs(y_distance) <= TOP_STICK_RADIUS:
			return
			
		if x_distance != 0 && sign(velocity.x) == sign(x_distance):
			velocity.x = 0
			ground_speed = 0
			
		position.x -= x_distance
	else:
		if y_distance < 0:
			if velocity.y < 0:
				velocity.y = 0
				position.y -= y_distance
		else:
			if y_distance >= 16:
				return 
						
			var x_cmp = (obj_pos.x + obj_hb.width_radius) - pl_pos.x 
			var obj_action_width = 1 + 2*obj_hb.width_radius
			if (velocity.y >= 0 && obj_action_width >= x_cmp && x_cmp >= 0):
				position.y -= (y_distance - TOP_STICK_RADIUS + 1)
				state_grounded.transition_land_on_object(self)
			

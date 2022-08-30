extends Node2D

const RUN_SPEED = 6.0

var ground_speed: float = 0.0
var angle: int = 0
var velocity: Vector2 = Vector2()

var input_h = 0
var input_v = 0

onready var sprite = $Sprite

onready var state_grounded = $StateGrounded
onready var state_airborne = $StateAirborne
onready var _states = [state_grounded, state_airborne]
onready var _state = state_grounded


#warning-ignore:unused_argument
func _process(delta):
	input_h = \
		int(Input.is_action_pressed("control_move_right")) \
		- int(Input.is_action_pressed("control_move_left"))
		
	input_v = \
		int(Input.is_action_pressed("control_move_down")) \
		- int(Input.is_action_pressed("control_move_up"))
		
	_state.animate_player(self)
	sprite.global_position = global_position.floor()
	
	
func _ready():
	for s in _states:
		if s != _state:
			remove_child(s)
	
func set_state(new_state):
	remove_child(_state)
	add_child(new_state)
	_state = new_state
	

func set_animation(anim):
	if $AnimationPlayer.current_animation != anim:
		$AnimationPlayer.play(anim)


func set_animation_ticks(n):
	$AnimationPlayer.playback_speed = 60.0 / (n + 1)


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


func tick_physics(tile_map, tile_meta_array):
	_state.update_player(self, tile_map, tile_meta_array)




func prevent_wall_collision(wall_sensor, tile_map, tile_meta_array):
	var info = wall_sensor.get_offset_collision_info(velocity, tile_map, tile_meta_array)
	if info.distance < 0:
		ground_speed = 0
		velocity += info.distance * wall_sensor.direction_vec
		

func apply_floor_collision(collision):
	position += collision.distance * collision.sensor.direction_vec
	angle = collision.angle


func animate_rolling():
	if ground_speed < RUN_SPEED:
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
		if ground_speed < RUN_SPEED:
			set_animation("walk")
		else:
			set_animation("run")
		set_animation_ticks(max(0, floor(8 - abs(ground_speed))))
		
	sprite.rotation = -stepify(get_angle_rads(), PI / 4)

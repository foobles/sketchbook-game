extends Node2D

var tile_meta_array = load("res://assets/tile_sets/platforming_meta.tres").into_array()

var tiles = preload("res://singletons/tile_map_info.tres")

var fbf = false

func _ready():
	
	#$Camera.limit_left = rect.position.x 
	#$Camera.limit_right = rect.end.x 
	#$Camera.limit_top = rect.position.y 
	#Camera.limit_bottom = rect.end.y
	
	tiles.set_info(self, tile_meta_array)



func _physics_process(_delta):
	if Input.is_action_just_pressed("debug_toggle_fbf"):
		fbf = !fbf
	
	if !fbf || Input.is_action_just_pressed("debug_step"):
		var tree = get_tree()
		tree.call_group_flags(SceneTree.GROUP_CALL_REALTIME, "entities", "tick")
		tree.call_group_flags(SceneTree.GROUP_CALL_REALTIME, "entities", "tick_player_interaction", $Player)
		
		$Player.update_position_array()
		$Camera.track_player($Player)
		
		# warning-ignore:integer_division
		$BgCanvas/Background.material.set_shader_param("scroll", [int($Camera.position.x) / 4, 0])
	

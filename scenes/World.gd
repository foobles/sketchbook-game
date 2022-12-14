extends Node2D

var tile_meta_array = load("res://assets/tile_sets/platforming_meta.tres").into_array()

var tiles = preload("res://singletons/tile_map_info.tres")

func _ready():
	var rect = $TileMap.get_used_rect()
	rect.position.x *= $TileMap.cell_size.x 
	rect.position.y *= $TileMap.cell_size.y 
	rect.size.x *= $TileMap.cell_size.x 
	rect.size.y *= $TileMap.cell_size.y 
	
	#$Camera.limit_left = rect.position.x 
	#$Camera.limit_right = rect.end.x 
	#$Camera.limit_top = rect.position.y 
	#Camera.limit_bottom = rect.end.y
	
	tiles.set_info($TileMap, tile_meta_array)

func _physics_process(_delta):
	var tree = get_tree()
	tree.call_group_flags(SceneTree.GROUP_CALL_REALTIME, "entities", "tick")
	tree.call_group_flags(SceneTree.GROUP_CALL_REALTIME, "entities", "tick_player_interaction", $Player)
	
	$Player.update_position_array()
	$Camera.track_player($Player)
	

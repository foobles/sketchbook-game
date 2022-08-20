extends Node2D

var tile_meta_array = load("res://assets/tile_sets/platforming_meta.tres").into_array()


func _ready():
	var rect = $TileMap.get_used_rect()
	rect.position.x *= $TileMap.cell_size.x 
	rect.position.y *= $TileMap.cell_size.y 
	rect.size.x *= $TileMap.cell_size.x 
	rect.size.y *= $TileMap.cell_size.y 
	
	$Camera2D.limit_left = rect.position.x 
	$Camera2D.limit_right = rect.end.x 
	$Camera2D.limit_top = rect.position.y 
	$Camera2D.limit_bottom = rect.end.y


func _process(delta):
	$Camera2D.position = $Player.position


func _physics_process(delta):
	$Player.update_ground_speed()
	$Player.apply_ground_speed()
	$Player.snap_to_floor($TileMap, tile_meta_array)

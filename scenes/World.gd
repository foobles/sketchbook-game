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

#warning-ignore:unused_argument
func _process(delta):
	$Camera2D.position = $Player.position.floor()


#warning-ignore:unused_argument
func _physics_process(delta):
	$Player.tick_physics($TileMap, tile_meta_array)

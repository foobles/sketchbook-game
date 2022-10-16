extends Resource

signal tiles_updated

var map: TileMap
var collisions: Array
var meta

func set_info(new_map, new_meta):
	map = new_map
	collisions = [
		map.get_node("CollisionMap0"), 
		map.get_node("CollisionMap1")
	]
	meta = new_meta
	emit_signal("tiles_updated")

extends Resource

signal tiles_updated

var map: TileMap
var meta

func set_info(new_map, new_meta):
	map = new_map
	meta = new_meta
	emit_signal("tiles_updated")

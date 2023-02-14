extends Resource

signal tiles_updated

var map: TileMap
var collision_maps: Array
var direction_mask_maps: Array
var meta

const direction_mask_tiles = preload("res://assets/tile_sets/direction_mask.tres");
# Bit pattern:
# 3 2 1 0
# | | | +- left 
# | | +--- bottom
# | +----- right
# +------- top
const direction_mask_name_to_bitset = {
	"MASK_T": 0b1000
}
var direction_mask_id_to_bitset = []

func _init():
	var mask_tile_ids = direction_mask_tiles.get_tiles_ids()
	direction_mask_id_to_bitset.resize(direction_mask_tiles.get_last_unused_tile_id())
	for mask_id in mask_tile_ids:
		var tile_name = direction_mask_tiles.tile_get_name(mask_id)
		direction_mask_id_to_bitset[mask_id] = direction_mask_name_to_bitset[tile_name]
	

func set_info(new_map, new_meta):
	map = new_map.get_node("TileMap")
	collision_maps = [
		new_map.get_node("CollisionMap0"), 
		new_map.get_node("CollisionMap1")
	]
	direction_mask_maps = []
	for c in collision_maps:
		direction_mask_maps.append(c.get_node("DirectionMask"))
	meta = new_meta
	emit_signal("tiles_updated")

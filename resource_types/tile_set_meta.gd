extends Resource

class_name TileSetMeta

export(TileSet) var tile_set = null
export(Array, Resource) var tile_attributes = []

func into_array():
	var ret = []
	ret.resize(tile_set.get_last_unused_tile_id())
	for attribute in tile_attributes:
		attribute.compute_widths()
		assert(len(attribute.heights) == 16)
		assert(len(attribute.widths) == 16)
		var idx = tile_set.find_tile_by_name(attribute.name)
		ret[idx] = attribute 

	return ret 

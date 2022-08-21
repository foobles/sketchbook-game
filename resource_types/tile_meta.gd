extends Resource

class_name TileMeta

export(String) var name = ""
export(PoolIntArray) var heights
var widths: PoolIntArray
export(int, 0, 256) var angle = 0

export(bool) var is_solid_top = true
export(bool) var is_solid_sides = true
export(bool) var is_solid_bottom = true

func compute_widths():
	widths = PoolIntArray()
	widths.resize(16)
	
	for i in range(16):
		var min_overlap_height = 16 - i
		widths[i] = 0
		for j in range(16):
			if heights[j] >= min_overlap_height:
				widths[i] = 16 - j 
				break

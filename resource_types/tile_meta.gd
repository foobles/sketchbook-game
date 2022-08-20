extends Resource

class_name TileMeta

export(String) var name = ""
export(PoolIntArray) var heights
export(PoolIntArray) var widths
export(float, 0, 2) var angle = 0

export(bool) var is_solid_top = true
export(bool) var is_solid_sides = true
export(bool) var is_solid_bottom = true

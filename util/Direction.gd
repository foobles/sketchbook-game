extends Object

class_name Direction

enum {
	RIGHT = 0,
	UP = 1,
	LEFT = 2,
	DOWN = 3
}

const MIN = RIGHT
const MAX = DOWN

static func is_horizontal(dir):
	return dir & 1 == 0
	
static func is_vertical(dir):
	return dir & 1 != 0
	
static func to_vec(dir):
	match dir:
		RIGHT:	return Vector2.RIGHT 
		UP:		return Vector2.UP 
		LEFT:	return Vector2.LEFT 
		DOWN:	return Vector2.DOWN 
		

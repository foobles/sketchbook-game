class_name StringUtil

static func pad_even(s):
	if len(s) & 1 == 0:
		return s 
	else:
		return s + ' '

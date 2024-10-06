extends Node
class_name PathGenerator

var _loop_count:int
var _path_route:Array[Vector2i]

const BASIC_PATH_CONFIG:PathGeneratorConfig = preload("res://resources/basic_path_config.res")

func _init() -> void:
	generate_path(BASIC_PATH_CONFIG.has_to_add_loops)
	
	while(
		_path_route.size() < BASIC_PATH_CONFIG.min_path_size or _path_route.size() > BASIC_PATH_CONFIG.max_path_size
		or _loop_count < BASIC_PATH_CONFIG.min_loops or _loop_count > BASIC_PATH_CONFIG.max_loops
	):
		generate_path(BASIC_PATH_CONFIG.has_to_add_loops)
	
func generate_path(add_loops:bool = false) -> Array[Vector2i]:
	_path_route.clear()

	randomize()

	_loop_count = 0
	
	var x:int = 0
	var y:int = int(BASIC_PATH_CONFIG.map_height / 2)

	while x < BASIC_PATH_CONFIG.map_length:
		if not _path_route.has(Vector2i(x, y)):
			_path_route.append(Vector2i(x, y))

		var choice:int = randi_range(0, 2)

		if choice == 0 or x % 2 == 0 or x == BASIC_PATH_CONFIG.map_length - 1:
			x += 1
		elif choice == 1 and y < BASIC_PATH_CONFIG.map_height - 2 and not _path_route.has(Vector2i(x, y + 1)):
			y += 1
		elif choice == 2 and y > 1 and not _path_route.has(Vector2i(x, y - 1)):
			y -= 1

	if add_loops:
		_add_loops()

	return _path_route

func _add_loops() -> void:
	var has_to_add_loops:bool = true
	
	while has_to_add_loops:
		has_to_add_loops = false
		
		for i in range(_path_route.size()):
			var loop:Array[Vector2i] = _is_loop_option(i)
			
			if loop.size() > 0:
				has_to_add_loops = true

				for j in range(loop.size()):
					_path_route.insert(i + 1 + j, loop[j])

func _is_loop_option(index:int) -> Array[Vector2i]:
	var x:int = _path_route[index].x
	var y:int = _path_route[index].y
	var return_path:Array[Vector2i]
	
	if (x < BASIC_PATH_CONFIG.map_length - 1 and y > 1
		and _tile_loc_free(x, y - 3) and _tile_loc_free(x + 1, y - 3) and _tile_loc_free(x + 2, y - 3)
		and _tile_loc_free(x - 1, y - 2) and _tile_loc_free(x, y - 2) and _tile_loc_free(x + 1, y - 2) and _tile_loc_free(x + 2, y - 2) and _tile_loc_free(x + 3, y - 2)
		and _tile_loc_free(x - 1, y - 1) and _tile_loc_free(x, y - 1) and _tile_loc_free(x + 1, y - 1) and _tile_loc_free(x + 2, y - 1) and _tile_loc_free(x + 3, y - 1)
		and _tile_loc_free(x + 1, y) and _tile_loc_free(x + 2, y) and _tile_loc_free(x + 3, y)
		and _tile_loc_free(x + 1,y + 1) and _tile_loc_free(x + 2,y + 1)):
		return_path = [Vector2i(x + 1, y), Vector2i(x + 2, y), Vector2i(x + 2, y - 1), Vector2i(x + 2, y - 2), Vector2i(x + 1, y - 2), Vector2i(x, y - 2), Vector2i(x, y - 1)]

		if _path_route[index - 1].y > y:
			return_path.reverse()
			
		_loop_count += 1
		return_path.append(Vector2i(x, y))
	elif (x > 2 and y > 1
			and _tile_loc_free(x, y - 3) and _tile_loc_free(x - 1, y - 3) and _tile_loc_free(x - 2, y - 3)
			and _tile_loc_free(x - 1, y) and _tile_loc_free(x - 2, y) and _tile_loc_free(x - 3, y)
			and _tile_loc_free(x + 1, y - 1) and _tile_loc_free(x, y - 1) and _tile_loc_free(x - 2, y - 1) and _tile_loc_free(x - 3, y - 1)
			and _tile_loc_free(x + 1, y - 2) and _tile_loc_free(x, y - 2) and _tile_loc_free(x - 1, y - 2) and _tile_loc_free(x - 2, y - 2) and _tile_loc_free(x - 3, y - 2)
			and _tile_loc_free(x - 1, y + 1) and _tile_loc_free(x - 2, y + 1)):
		return_path = [Vector2i(x, y - 1), Vector2i(x, y - 2), Vector2i(x - 1, y - 2), Vector2i(x - 2, y - 2), Vector2i(x - 2, y - 1), Vector2i(x - 2, y), Vector2i(x - 1, y)]

		if _path_route[index - 1].x > x:
			return_path.reverse()

		_loop_count += 1
		return_path.append(Vector2i(x, y))
	elif (x < BASIC_PATH_CONFIG.map_length - 1 and y < BASIC_PATH_CONFIG.map_height - 2
			and _tile_loc_free(x, y + 3) and _tile_loc_free(x + 1, y + 3) and _tile_loc_free(x + 2, y + 3)
			and _tile_loc_free(x + 1, y - 1) and _tile_loc_free(x + 2, y - 1)
			and _tile_loc_free(x + 1, y) and _tile_loc_free(x + 2, y) and _tile_loc_free(x + 3, y)
			and _tile_loc_free(x - 1, y + 1) and _tile_loc_free(x, y + 1) and _tile_loc_free(x + 2, y+1) and _tile_loc_free(x + 3, y + 1)
			and _tile_loc_free(x - 1, y + 2) and _tile_loc_free(x, y + 2) and _tile_loc_free(x + 1, y+2) and _tile_loc_free(x + 2, y + 2) and _tile_loc_free(x + 3, y + 2)):
		return_path = [Vector2i(x + 1, y), Vector2i(x + 2, y), Vector2i(x + 2, y + 1), Vector2i(x + 2, y + 2), Vector2i(x + 1, y + 2), Vector2i(x, y + 2), Vector2i(x, y + 1)]

		if _path_route[index - 1].y < y:
			return_path.reverse()
		
		_loop_count += 1
		return_path.append(Vector2i(x, y))
	elif (x > 2 and y < BASIC_PATH_CONFIG.map_height - 2
			and _tile_loc_free(x, y + 3) and _tile_loc_free(x - 1, y + 3) and _tile_loc_free(x - 2, y + 3)
			and _tile_loc_free(x - 1, y - 1) and _tile_loc_free(x - 2, y - 1)
			and _tile_loc_free(x - 1, y) and _tile_loc_free(x - 2, y) and _tile_loc_free(x - 3, y)
			and _tile_loc_free(x + 1, y + 1) and _tile_loc_free(x, y + 1) and _tile_loc_free(x - 2, y + 1) and _tile_loc_free(x - 3, y + 1)
			and _tile_loc_free(x + 1, y + 2) and _tile_loc_free(x, y + 2) and _tile_loc_free(x - 1, y + 2) and _tile_loc_free(x - 2, y + 2) and _tile_loc_free(x - 3, y + 2)):
		return_path = [Vector2i(x, y + 1), Vector2i(x, y + 2), Vector2i(x - 1,y + 2), Vector2i(x - 2,y + 2), Vector2i(x - 2,y + 1), Vector2i(x - 2, y), Vector2i(x - 1, y)]

		if _path_route[index - 1].x > x:
			return_path.reverse()
		
		_loop_count += 1
		return_path.append(Vector2i(x, y))
		
	return return_path

# Returns true if there is a path tile at the x, y coordinate.
func _tile_loc_taken(x: int, y: int) -> bool:
	return _path_route.has(Vector2i(x, y))
	
# Returns true if there is no path tile at the x, y coordinate.
func _tile_loc_free(x: int, y: int) -> bool:
	return not _path_route.has(Vector2i(x, y))

# Returns the number of loops currently in the path.
func get_loop_count() -> int:
	return _loop_count

func get_path_tile(index:int) -> Vector2i:
	return _path_route[index]

#		1
#	8		2
#		4
func get_tile_score(index:int) -> int:
	var score:int = 0
	var x:int = _path_route[index].x
	var y:int = _path_route[index].y
	
	score += 1 if _path_route.has(Vector2i(x, y - 1)) else 0
	score += 2 if _path_route.has(Vector2i(x + 1, y)) else 0
	score += 4 if _path_route.has(Vector2i(x, y + 1)) else 0
	score += 8 if _path_route.has(Vector2i(x - 1, y)) else 0
	
	return score

func get_path_route() -> Array[Vector2i]:
	return _path_route

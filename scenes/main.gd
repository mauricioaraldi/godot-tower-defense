extends Node3D

@export var tile_tip:PackedScene
@export var tile_straight:PackedScene
@export var tile_crossroads:PackedScene
@export var tile_corner:PackedScene
@export var tile_empty:Array[PackedScene]

@export var basic_enemy:PackedScene

const BASIC_PATH_CONFIG:PathGeneratorConfig = preload("res://resources/basic_path_config.res")

# Called when the node enters the scene tree for the first time.
func _ready():
	_complete_grid()

	await get_tree().create_timer(2).timeout

	_pop_along_grid()

func _pop_along_grid():
	for i in 20:
		await get_tree().create_timer(2).timeout
		var box = basic_enemy.instantiate()
		add_child(box)

func _complete_grid():
	for x in range(BASIC_PATH_CONFIG.map_length):
		for y in range(BASIC_PATH_CONFIG.map_height):
			if not PathGenInstance.get_path_route().has(Vector2i(x, y)):
				var tile:Node3D = tile_empty.pick_random().instantiate()

				add_child(tile)

				tile.global_position = Vector3(x, 0, y)
				tile.global_rotation_degrees = Vector3(0, randi_range(0, 3) * 90 , 0)
				
	for i in range(PathGenInstance.get_path_route().size()):
		var tile_score:int = PathGenInstance.get_tile_score(i)
		var tile:Node3D = tile_empty[0].instantiate()
		var tile_rotation:Vector3 = Vector3.ZERO
		
		if tile_score == 2:
			tile = tile_tip.instantiate()
			tile_rotation = Vector3(0, 90, 0)
		if tile_score == 8:
			tile = tile_tip.instantiate()
			tile_rotation = Vector3(0, -90, 0)
		if tile_score == 10:
			tile = tile_straight.instantiate()
			tile_rotation = Vector3(0, 90, 0)
		elif tile_score == 1 or tile_score == 4 or tile_score == 5:
			tile = tile_straight.instantiate()
			tile_rotation = Vector3(0, 0, 0)
		elif tile_score == 3:
			tile = tile_corner.instantiate()
			tile_rotation = Vector3(0, 90, 0)
		elif tile_score == 6:
			tile = tile_corner.instantiate()
			tile_rotation = Vector3(0, 0, 0)
		elif tile_score == 9:
			tile = tile_corner.instantiate()
			tile_rotation = Vector3(0, 180, 0)
		elif tile_score == 12:
			tile = tile_corner.instantiate()
			tile_rotation = Vector3(0, 270, 0)
		elif tile_score == 15:
			tile = tile_crossroads.instantiate()
			tile_rotation = Vector3(0, 0, 0)

		add_child(tile)
		
		tile.global_position = Vector3(PathGenInstance.get_path_tile(i).x, 0, PathGenInstance.get_path_tile(i).y)
		tile.global_rotation_degrees = tile_rotation

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

extends Button

@export var activity_button_icon: Texture2D
@export var button_draggable: PackedScene

var _draggable: Node
var _cam: Camera3D

var RAYCAST_LENGTH: int = 100

var _is_dragging: bool = false
var _is_valid_location: bool = false
var _last_valid_location: Vector3

var _drag_alpha: float = 0.5

@onready var error_mat: BaseMaterial3D = preload("res://materials/red_transparent.material")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	icon = activity_button_icon
	_draggable = button_draggable.instantiate()
	_draggable.set_patrolling(false)
	add_child(_draggable)
	_draggable.visible = false
	_cam = get_viewport().get_camera_3d()

func _physics_process(_delta):
	if _is_dragging:
		var space_state = _draggable.get_world_3d().direct_space_state
		var mouse_pos: Vector2 = get_viewport().get_mouse_position()
		var origin: Vector3 = _cam.project_ray_origin(mouse_pos)
		var end: Vector3 = origin + _cam.project_ray_normal(mouse_pos) * RAYCAST_LENGTH
		var query = PhysicsRayQueryParameters3D.create(origin, end)

		query.collide_with_areas = true

		var rayResult: Dictionary = space_state.intersect_ray(query)

		if rayResult.size() > 0:
			var co: CollisionObject3D = rayResult.get("collider")
			_on_main_mouse_hit(co)
		else:
			_draggable.visible = false
			_is_valid_location = false


func set_child_mesh_alphas(n: Node):
	for c in n.get_children():
		if c is MeshInstance3D:
			set_mesh_alpha(c)

		if c is Node and c.get_child_count() > 0:
			set_child_mesh_alphas(c)


func set_mesh_alpha(mesh_3d: MeshInstance3D):
	for si in mesh_3d.mesh.get_surface_count():
		mesh_3d.set_surface_override_material(si, mesh_3d.mesh.surface_get_material(si).duplicate(true))
		mesh_3d.get_surface_override_material(si).transparency = 1
		mesh_3d.get_surface_override_material(si).albedo_color.a = _drag_alpha

func set_child_mesh_error(n: Node):
	for c in n.get_children():
		if c is MeshInstance3D:
			set_mesh_error(c)

		if c is Node and c.get_child_count() > 0:
			set_child_mesh_error(c)


func set_mesh_error(mesh_3d: MeshInstance3D):
	for si in mesh_3d.mesh.get_surface_count():
		mesh_3d.set_surface_override_material(si, error_mat)


func clear_material_overrides(n: Node):
	for c in n.get_children():
		if c is MeshInstance3D:
			clear_material_override(c)

		if c is Node and c.get_child_count() > 0:
			clear_material_overrides(c)


func clear_material_override(mesh_3d: MeshInstance3D):
	for si in mesh_3d.mesh.get_surface_count():
		mesh_3d.set_surface_override_material(si, null)


func _on_main_mouse_hit(tile: CollisionObject3D):
	_draggable.visible = true
	
	if tile.get_groups()[0].begins_with("grid_empty"):
		set_child_mesh_alphas(_draggable)
		_draggable.global_position = Vector3(tile.global_position.x, 0.2, tile.global_position.z)
		_last_valid_location = _draggable.global_position
		_is_valid_location = true
		clear_material_overrides(_draggable)
	else:
		set_child_mesh_error(_draggable)
		_draggable.global_position = Vector3(tile.global_position.x, 0.2, tile.global_position.z)
		_is_valid_location = false


func _on_button_down() -> void:
	_is_dragging = true
	_is_valid_location = false;


func _on_button_up() -> void:
	_is_dragging = false
	_draggable.visible = false

	if _is_valid_location:
		var new_object: Node3D = button_draggable.instantiate()
		get_viewport().add_child(new_object)
		new_object.global_position = _last_valid_location

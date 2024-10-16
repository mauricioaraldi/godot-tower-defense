extends Node3D

var enemies_in_range: Array[Node3D]
var current_enemy: Node3D = null
var current_enemy_targetted: bool = false
var acquire_slerp_progress: float = 0
var last_fire_time: int

@export var fire_rate_ms: int = 1000
@export var projectile_type: PackedScene

func _on_patrol_zone_area_entered(area: Area3D) -> void:
	if current_enemy == null and area.get_parent().get_parent().get_parent().attackable:
		current_enemy = area

	enemies_in_range.append(area)


func _on_patrol_zone_area_exited(area: Area3D) -> void:
	enemies_in_range.erase(area)


func set_patrolling(patrolling: bool) -> void:
	$PatrolZone.monitoring = patrolling


func rotate_towards_target(rtarget, delta):
	var target_vector = $roof.global_position.direction_to(
		Vector3(
			rtarget.global_position.x,
			global_position.y,
			rtarget.global_position.z
		)
	)
	var target_basis: Basis = Basis.looking_at(target_vector)

	$roof.basis = $roof.basis.slerp(target_basis, acquire_slerp_progress)
	acquire_slerp_progress += delta

	if acquire_slerp_progress > 1:
		$StateChart.send_event("to_attacking")


func _on_acquiring_state_state_physics_processing(delta):
	if current_enemy != null and enemies_in_range.has(current_enemy):
		rotate_towards_target(current_enemy, delta)
	else:
		$StateChart.send_event("to_patrolling")


func _on_attacking_state_state_physics_processing(delta):
	if current_enemy != null and enemies_in_range.has(current_enemy):
		$roof.look_at(current_enemy.global_position)
		_maybe_fire()
	else:
		$StateChart.send_event("to_patrolling")


func _on_patrolling_state_state_processing(delta):
	if enemies_in_range.size() > 0:
		current_enemy = enemies_in_range[enemies_in_range.size() - 1]
		$StateChart.send_event("to_acquiring")


func _on_acquiring_state_entered() -> void:
	current_enemy_targetted = false
	acquire_slerp_progress = 0


func _maybe_fire():
	if Time.get_ticks_msec() > (last_fire_time + fire_rate_ms):
		var projectile:Projectile = projectile_type.instantiate()
		projectile.starting_position = $roof/projectile_spawn.global_position
		projectile.target = current_enemy
		add_child(projectile)
		$AudioShoot.play()
		last_fire_time = Time.get_ticks_msec()


func _on_attacking_state_state_entered() -> void:
	last_fire_time = 0

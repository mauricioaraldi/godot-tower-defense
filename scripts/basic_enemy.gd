extends Node3D

@export var ENEMY_SETTINGS:EnemySettings

var health:int

var attackable:bool = false
var distance_travelled:float = 0

var path_3d:Path3D
var path_follow_3d:PathFollow3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = ENEMY_SETTINGS.health
	$Path3D.curve = path_route_to_curve_3d()
	$Path3D/PathFollow3D.progress = 0


func _process(delta: float) -> void:
	if health < 0:
		attackable = false
		$EnemyStateChart.send_event("to_dying")


func path_route_to_curve_3d() -> Curve3D:
	var c3d: Curve3D = Curve3D.new()

	for element in PathGenInstance.get_path_route():
		c3d.add_point(Vector3(element.x, 0.25, element.y))

	return c3d


func _on_spawning_state_entered() -> void:
	attackable = false
	$AnimationPlayer.play("spawn")
	await $AnimationPlayer.animation_finished
	$EnemyStateChart.send_event("to_travelling")


func _on_travelling_state_entered() -> void:
	attackable = true


func _on_travelling_state_processing(delta: float) -> void:
	distance_travelled += (delta * ENEMY_SETTINGS.speed)
	var distance_travelled_on_screen: float = clamp(
		distance_travelled, 0, PathGenInstance.get_path_route().size() - 1
	)
	$Path3D/PathFollow3D.progress = distance_travelled_on_screen

	if distance_travelled > PathGenInstance.get_path_route().size() - 1:
		$EnemyStateChart.send_event("to_damage_player")


func _on_despawning_state_entered() -> void:
	$AnimationPlayer.play("despawn")
	await $AnimationPlayer.animation_finished
	queue_free()


func _on_damage_player_state_entered() -> void:
	attackable = false
	$EnemyStateChart.send_event("to_despawning")


func _on_dying_state_entered() -> void:
	$AudioDying.play()

	$Path3D/PathFollow3D/Explosion.emitting = true;
	$Path3D/PathFollow3D/Smoke.emitting = true

	$EnemyStateChart.send_event("to_despawning")

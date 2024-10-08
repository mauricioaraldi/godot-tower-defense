extends Node3D

var curve_3d:Curve3D
var enemy_progress:float = 0
var enemy_speed:float = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	curve_3d = Curve3D.new()
	
	for i in PathGenInstance.get_path_route():
		curve_3d.add_point(Vector3(i.x, 0, i.y))
		
	$Path3D.curve = curve_3d
	$Path3D/PathFollow3D.progress_ratio = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_spawning_state_entered() -> void:
	$AnimationPlayer.play("spawn")
	await $AnimationPlayer.animation_finished
	$EnemyStateChart.send_event("to_travelling")


func _on_travelling_state_entered() -> void:
	pass # Replace with function body.


func _on_travelling_state_processing(delta: float) -> void:
	enemy_progress += delta * enemy_speed
	$Path3D/PathFollow3D.progress = enemy_progress

	if enemy_progress > PathGenInstance.get_path_route().size():
		$EnemyStateChart.send_event("to_despawning")


func _on_despawning_state_entered() -> void:
	$AnimationPlayer.play("despawn")
	await $AnimationPlayer.animation_finished
	queue_free()

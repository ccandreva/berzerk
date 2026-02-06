extends Area2D

var speed = 100
var remove_laser : Callable

func _physics_process(_delta: float) -> void:
	position += transform.x * speed * _delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		body.kill_player()
	if body.is_in_group("Robots"):
		body.kill_robot()
	if (remove_laser != null):
		remove_laser.call()
	queue_free()

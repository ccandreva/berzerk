extends Area2D

@onready var collision:CollisionShape2D = $ExitCollision

signal exit_triggered(exit_name: String)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		print("Exit triggered by: ", body)
		exit_triggered.emit(self.name)

func disable() ->void:
	collision.set_deferred("disabled",true)
	print ("Exit Disabled")

func enable() -> void:
	collision.set_deferred("disabled",false)
	print ("Exit Enabled")

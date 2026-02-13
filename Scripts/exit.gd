extends Area2D

signal exit_triggered(exit_name: String)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		print("Exit triggered by: ", body)
		exit_triggered.emit(self.name)

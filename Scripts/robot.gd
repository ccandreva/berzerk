extends CharacterBody2D


func _on_collision_target_body_entered(body: Node2D) -> void:
	print ("Robot Body Hit!")


func _on_collision_target_area_entered(area: Area2D) -> void:
	print ("Robot Area Hit!")

extends StaticBody2D

@onready var arms : Node2D = get_node("./Arms")

func set_arm(direction: int=0, state: bool = true) -> void:
	
	# Activate one of the four direciton arms randomly
	var arm : StaticBody2D = arms.get_child(direction)

	# Turn on it's collision and set it to visible
	arm.set_collision_layer_value(2, state)
	arm.visible = state

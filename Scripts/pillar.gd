extends StaticBody2D

@onready var arms : Node2D = get_node("./Arms")

func _ready() -> void:
	
	# Activate one of the four direciton arms randomly
	var direction : int = randi_range(0,3)
	var arm : StaticBody2D = arms.get_child(direction)

	# Turn on it's collision and set it to visible
	arm.set_collision_layer_value(1, true)
	arm.visible = true
	

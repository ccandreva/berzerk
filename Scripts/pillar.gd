extends Area2D

@onready var arms : Node2D = get_node("./Arms")

func _ready() -> void:
	
	var direction : int = randi_range(0,3)
	print(str(self.name, " direciton: ", direction))
	arms.get_child(direction).visible = true

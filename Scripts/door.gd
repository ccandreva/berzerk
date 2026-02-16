extends StaticBody2D

@onready var sprite:Sprite2D = $Sprite2D
@onready var collision:CollisionShape2D = $CollisionShape2D

func open() -> void:
	sprite.visible = false
	collision.disabled = true


func close() -> void:
	sprite.visible = true
	collision.disabled = false

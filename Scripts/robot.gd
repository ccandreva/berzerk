extends CharacterBody2D

# Player speed
@export var speed:int = 50

@onready var sprite:AnimatedSprite2D = get_node("AnimatedSprite2D")
var direction:String=""
# States: Idle, Walking, Shooting, Death
var state:String="Idle"

func _physics_process(_delta: float) -> void:
	# Play an animation based on the directions we built, 
	# or if we are dead.
	sprite.play(str(state,direction))


func kill_robot() -> void:
	state = "Death"
	direction = ""


func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()

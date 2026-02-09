extends CharacterBody2D

# Get node instances we will need
@onready var player: CharacterBody2D = get_node("/root/Main/Player")

# Otto's speed
@export var speed:int = 20

var sprite:AnimatedSprite2D
var collision:CollisionShape2D
var collision_y : Array = [-2.5, -20, -28, -32, -34, -36, -34, -32, -28, -20 ]
var collision_scale_y:Array = [0.7,1,1,1,1,1,1,1,1,1]
var start_position:Vector2

func _ready() -> void:
	sprite = get_node("AnimatedSprite2D")
	collision = get_node("OttoTrigger/CollisionOtto")
	$OttoTrigger.body_entered.connect(Callable(self,"_on_otto_trigger_body_entered"))
	start_position = position
	disable_otto()
	init_otto()

func _physics_process(_delta: float) -> void:
	if ( is_instance_valid(player)):
		var direction_vector:Vector2 = ( player.global_position - self.global_position).normalized()
		# Lock direction to 8-bit 8-way positions
		if (direction_vector != Vector2.ZERO):
			direction_vector = direction_vector.snapped(Vector2(0.5,0.5)).normalized()
			velocity=direction_vector * speed
			move_and_slide()

# Disable otto by stopping processing
# And movving off the playing field
func disable_otto():
	process_mode=Node.PROCESS_MODE_DISABLED
	position=Vector2i(-5000,-5000)


func init_otto():
	position=start_position
	collision.position.y = collision_y[0]
	collision.scale.y = collision_scale_y[0]
	process_mode=Node.PROCESS_MODE_INHERIT
	sprite.play("Spawn")
	sprite.animation_finished.connect(Callable(self,"_on_animation_finished"))


func _on_animation_finished() -> void:
	sprite.play("Bounce")
	sprite.animation_finished.disconnect(Callable(self,"_on_animation_finished"))
	sprite.connect("frame_changed", Callable(self, "_on_frame_changed"))


func _on_frame_changed() -> void:
	# Move Otto's sprite collision shape with his head.
	collision.position.y = collision_y[sprite.frame]
	collision.scale.y = collision_scale_y[sprite.frame]


func _on_otto_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("Robots"):
		body.kill_robot()
	elif body.is_in_group("Players"):
		body.kill_player()
	

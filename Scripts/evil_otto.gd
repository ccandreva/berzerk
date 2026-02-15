extends CharacterBody2D

# Get node instances we will need
var player: CharacterBody2D
@onready var timer_otto_spawn : Timer = get_node("TimerOttoSpawn")

# Otto's speed
@export var speed:int = 20

var sprite:AnimatedSprite2D
var collision:CollisionShape2D
# Collision y positions to follow the bouncing head
var collision_y : Array = [-2.5, -20, -28, -32, -34, -36, -34, -32, -28, -20 ]
# Squash the hit box for spawn in
var collision_scale_y:Array = [0.7,1,1,1,1,1,1,1,1,1]
var start_position:Vector2
var state:String = "Idle"
var color:Color

func _ready() -> void:
	sprite = get_node("AnimatedSprite2D")
	sprite.set_instance_shader_parameter("new_color", color)
	collision = get_node("OttoTrigger/CollisionOtto")
	$OttoTrigger.body_entered.connect(Callable(self,"_on_otto_trigger_body_entered"))
	timer_otto_spawn.timeout.connect(Callable(self, "spawn_otto"))
	start_position = Vector2(103,407)
	disable_otto()
	init_otto()

func _physics_process(_delta: float) -> void:
	if ( (state == "Bounce") and is_instance_valid(player)):
		var direction_vector:Vector2 = ( player.global_position - self.global_position).normalized()
		# Lock direction to 8-bit 8-way positions
		if (direction_vector != Vector2.ZERO):
			direction_vector = direction_vector.snapped(Vector2(0.5,0.5)).normalized()
			velocity=direction_vector * speed
			move_and_slide()

func pause_otto():
	process_mode=Node.PROCESS_MODE_DISABLED

# Disable otto by stopping processing
# And moving off the playing field
func disable_otto():
	if (state == "Bounce"):
		sprite.disconnect("frame_changed", Callable(self, "_on_frame_changed"))
	process_mode=Node.PROCESS_MODE_DISABLED
	position=Vector2i(-5000,-5000)


func init_otto():
	process_mode=Node.PROCESS_MODE_INHERIT
	position=Vector2i(-5000,-5000)
	state = "Idle"
	sprite.set_instance_shader_parameter("new_color", color)
	sprite.play("Idle")
	timer_otto_spawn.start()
	
func spawn_otto():
	state="Spawn"
	position=start_position
	collision.position.y = collision_y[0]
	collision.scale.y = collision_scale_y[0]
	process_mode=Node.PROCESS_MODE_INHERIT
	sprite.animation_finished.connect(Callable(self,"_on_animation_finished"))
	sprite.play("Spawn")


func _on_animation_finished() -> void:
	state="Bounce"
	sprite.play("Bounce")
	sprite.animation_finished.disconnect(Callable(self,"_on_animation_finished"))
	sprite.connect("frame_changed", Callable(self, "_on_frame_changed"))


func _on_frame_changed() -> void:
	# Move Otto's sprite collision shape with his head.
	collision.position.y = collision_y[sprite.frame]
	collision.scale.y = collision_scale_y[sprite.frame]


func _on_otto_trigger_body_entered(body: Node2D) -> void:
	# if body.has_method("die"):
	if body.is_in_group("Robots"):
		body.kill_robot()
	elif body.is_in_group("Players"):
		body.kill_player(self)
	

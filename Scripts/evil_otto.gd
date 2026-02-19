extends CharacterBody2D

# Otto's speed
@export var speed:int = 20

# Get node instances we will need
@onready var timer_otto_spawn : Timer = get_node("TimerOttoSpawn")
@onready var sprite:AnimatedSprite2D = get_node("AnimatedSprite2D")
@onready var collision:CollisionShape2D = get_node("OttoTrigger/CollisionOtto")

# Will be loaded from main
var player: CharacterBody2D
# Collision y positions to follow the bouncing head
var collision_y : Array = [-2.5, -20, -28, -32, -34, -36, -34, -32, -28, -20 ]
# Squash the hit box for spawn in
var collision_scale_y:Array = [0.7,1,1,1,1,1,1,1,1,1]
var start_position:Vector2
var state:String = "Idle"

func _ready() -> void:
	$OttoTrigger.body_entered.connect(Callable(self,"_on_otto_trigger_body_entered"))
	timer_otto_spawn.timeout.connect(Callable(self, "spawn_otto"))
	disable_otto()

func _physics_process(_delta: float) -> void:
	if ( (state == "Bounce") and is_instance_valid(player)):
		var direction_vector:Vector2 = ( player.global_position - self.global_position).normalized()
		# Lock direction to 8-bit 8-way positions
		if (direction_vector != Vector2.ZERO):
			direction_vector = direction_vector.snapped(Vector2(0.5,0.5)).normalized()
			velocity=direction_vector * speed
			move_and_slide()


# Disable otto by stopping processing
# And moving off the playing field
func disable_otto():
	if (state == "Bounce"):
		sprite.frame_changed.disconnect(Callable(self, "_on_frame_changed"))
	process_mode=Node.PROCESS_MODE_DISABLED
	position=Vector2i(-5000,-5000)

#
# Initialize Otto for each level with data from main
#
func init_otto(level_data: Dictionary, new_start_position: Vector2):
	start_position = new_start_position
	speed = player.speed * 0.45 #level_data["speed"]
	# Set Otto's color via a shader
	sprite.set_instance_shader_parameter("new_color", level_data["color"])
	sprite.speed_scale = 1
	process_mode=Node.PROCESS_MODE_INHERIT
	# Move Otto off screen until he spawns
	position=Vector2i(-5000,-5000)
	_set_state("Idle")
	timer_otto_spawn.start()


func fast() -> void:
	speed = player.speed * 0.9
	sprite.speed_scale = 2


#
# Spawn otto when timer runs out
#	
func spawn_otto():
	position=start_position
	collision.position.y = collision_y[0]
	collision.scale.y = collision_scale_y[0]
	process_mode=Node.PROCESS_MODE_INHERIT
	sprite.animation_finished.connect(Callable(self,"_on_animation_finished"))
	_set_state("Spawn")
	$IntruderAlert.play()


#
# Change to bounce state when spawn animatin ends
#
func _on_animation_finished() -> void:
	_set_state("Bounce")
	sprite.animation_finished.disconnect(Callable(self,"_on_animation_finished"))
	sprite.frame_changed.connect(Callable(self, "_on_frame_changed"))

#
# Set Otto's State and sprite to match
#
func _set_state(new_state:String):
	state=new_state
	sprite.play(state)


#
# Otto's bnoune sprite is one big image for the entire range of his bounce.
# When each frame of the bounce changes, move the collision shape
# to follow his head in the sprite
#
func _on_frame_changed() -> void:
	# Move Otto's sprite collision shape with his head.
	collision.position.y = collision_y[sprite.frame]
	collision.scale.y = collision_scale_y[sprite.frame]

#
# Kill whatever Otto hits
#
func _on_otto_trigger_body_entered(body: Node2D) -> void:
	# if body.has_method("die"):
	if body.is_in_group("Robots"):
		body.kill_robot()
	elif body.is_in_group("Players"):
		body.kill_player(self)

extends CharacterBody2D

signal robot_died

@export var Laser : PackedScene

# Get node instances we will need
@onready var player: CharacterBody2D = get_node("/root/Main/Player")
@onready var walk_timer: Timer = get_node("./WalkTimer")

# Robot speed
@export var speed:int = 20
@onready var sprite:AnimatedSprite2D = get_node("AnimatedSprite2D")
# States: Idle, Walk, Shoot, Death
var state:String="Idle"
var direction:String=""
var current_sprite: String
var is_shooting: bool = false
var start_position:Vector2i

func _ready() -> void:
	# Save our initial position
	start_position = position
	
func _physics_process(_delta: float) -> void:
	if ( is_instance_valid(player)):
		if (state == "Walk"):
			var direction_vector:Vector2 = _vector_to_target()
			var collision = move_and_collide(direction_vector * speed * _delta)
			if (collision):
				if (collision.get_collider().name == "Player"):
					player.kill_player()
				kill_robot()
	else:
		idle_robot()
	# Play an animation based on the directions we built, 
	# or if we are dead.
	_set_sprite(str(state,direction))

func _set_sprite(new_sprite:String) ->void:
	if (new_sprite != current_sprite):
		current_sprite = new_sprite
		sprite.play(current_sprite)


func _vector_to_target(is_8way:bool = false) -> Vector2:
	var direction_h:String
	var direction_v:String
	var direction_vector:Vector2 = Vector2.ZERO
	if (is_instance_valid(player)):
		var position_p:Vector2 = player.global_position
		var position_s:Vector2 = self.global_position
		direction_vector = ( position_p - position_s).normalized()
	# Lock direction to 8-bit 8-way positions
	if (direction_vector != Vector2.ZERO):
		direction_vector = direction_vector.snapped(Vector2(0.5,0.5)).normalized()
	# Set the direction label
	if (direction_vector.x<0):
		direction_h="Left"
	elif (direction_vector.x>0):
		direction_h="Right"
	if (direction_vector.y < 0):
		direction_v="Up"
	elif (direction_vector.y > 0):
		direction_v="Down"
	
	if is_8way:
		direction = str(direction_v,direction_h)
	else:
		direction = direction_v if direction_v else direction_h
	return(direction_vector)

func shoot(direction_vector: Vector2):
	# We can only shoot once, so skip if we are already shooting
	if (is_shooting):
		return
	var laser:Area2D = Laser.instantiate()
	laser.notify_spawner = Callable(self,"remove_laser")
	laser.set_direction(direction_vector, direction)
	# Set initial positoin to robot position,
	# plus a bit along the shot path
	laser.transform = self.global_transform
	laser.position += (direction_vector * 25)
	# Add to the parent, so it doesn't move with us.
	owner.add_child(laser)
	laser.active()
	is_shooting = true
	direction = ""
	
func remove_laser():
	is_shooting = false


func kill_robot() -> void:
	# We're dead, we can't collide any more
	set_collision_layer_value(1, false)
	robot_died.emit()
	walk_timer.stop()
	$DeathSound.play()
	state = "Death"
	direction = ""


func idle_robot():
	if (state != "Death"):
		state="Idle"
		direction=""
		var v:Vector2 = _vector_to_target(true) #* Vector2(randf_range(-0.02,0.02),randf_range(-0.02,0.02) )
		shoot(v.normalized() )


func walk_robot():
	if (state != "Death"):
		state="Walk"


# Disable robot by stopping processing
# And movving off the playing field
func disable_robot():
	process_mode=Node.PROCESS_MODE_DISABLED
	set_collision_layer_value(1, false)
	walk_timer.stop()
	position=Vector2i(-5000,-5000)

func init_robot():
	position=start_position
	state="Idle"
	set_collision_layer_value(1, true)
	process_mode=Node.PROCESS_MODE_INHERIT
	walk_timer.start(randf_range(0.5,1.5))
	process_mode=Node.PROCESS_MODE_INHERIT

func _on_animated_sprite_2d_animation_finished() -> void:
	walk_timer.stop()
	match state:
		"Death":
			disable_robot()
		"Walk":
			idle_robot()
			walk_timer.start(randf_range(0.5,1.5))

	

func _on_walk_timer_timeout() -> void:
	walk_robot()

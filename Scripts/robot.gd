extends CharacterBody2D

signal robot_died

@export var Laser : PackedScene

# Get node instances we will need
@onready var player: CharacterBody2D = get_node("/root/Main/GameScreen/Player")
@onready var shoot_timer: Timer = get_node("./ShootTimer")
@onready var RayCastNorth : RayCast2D = get_node("./CollisionShape2D/RayCastNorth")
@onready var RayCastSouth : RayCast2D = get_node("./CollisionShape2D/RayCastSouth")
@onready var RayCastEast : RayCast2D = get_node("./CollisionShape2D/RayCastEast")
@onready var RayCastWest : RayCast2D = get_node("./CollisionShape2D/RayCastWest")

# Robot speed
@export var speed:int = 20
@onready var sprite:AnimatedSprite2D = get_node("AnimatedSprite2D")
# States: Idle, Walk, Shoot, Death
var state:String="Idle"
var direction:String=""
var current_sprite: String
var laser_count:int = 0
var laser_max: int = 0
var start_position:Vector2i
var color:Color = Color(1,1,0)

func _ready() -> void:
	# Save our initial position
	start_position = position
	
func _physics_process(_delta: float) -> void:
	# Dead robots can't move or shoot
	if (state != "Death" and state != "Paused"):
		if ( is_instance_valid(player)):
			# Get vector to the player, allowing for raycast to the walls.
			var direction_vector:Vector2 =  _check_raycast(_vector_to_target())
			if (direction_vector != Vector2.ZERO):
				state = "Walk"
				# Get a four-way word to match Robot sprite annimation names
				_direction_vector_to_word(direction_vector, false)
				var collision = move_and_collide(direction_vector * speed * _delta)
				# If we walked into something we're dead. 
				if (collision):
					# So is the player if we walked into them
					var collider = collision.get_collider()
					if (collider.name == "Player"):
						player.kill_player(collider)
					kill_robot()
		#No player or no way to wlak, we are idle
		else:
			state = "Idle"
			direction=""
	# Play an animation based on the directions we built, 
	# or if we are dead.
	_set_sprite(str(state,direction))

func _set_sprite(new_sprite:String) ->void:
	if (new_sprite != current_sprite):
		$"Label".text=new_sprite
		sprite.play(new_sprite)
		current_sprite = new_sprite


func _vector_to_target() -> Vector2:
	var direction_vector:Vector2 = Vector2.ZERO
	if (is_instance_valid(player)):
		direction_vector = ( player.position - self.position).normalized()
	# Lock direction to 8-bit 8-way positions
	if (direction_vector != Vector2.ZERO):
		direction_vector = direction_vector.snapped(Vector2(0.5,0.5)).normalized()
	return(direction_vector)


func _check_raycast(direction_vector: Vector2):
	if (RayCastWest.is_colliding() or RayCastEast.is_colliding()):
		direction_vector.x = 0
	if (RayCastNorth.is_colliding() or RayCastSouth.is_colliding()):
		direction_vector.y = 0
	return(direction_vector)


func _direction_vector_to_word(direction_vector: Vector2, is_8way:bool = false):
	var direction_h:String
	var direction_v:String
	# Set the direction label
	if (direction_vector.x<0):
		direction_h="Left"
	elif (direction_vector.x>0):
		direction_h="Right"
	if (direction_vector.y < 0):
		direction_v="Up"
	elif (direction_vector.y > 0):
		direction_v="Down"
	
	# Handle difference between 8 and 4 way sprites
	if is_8way:
		direction = str(direction_v,direction_h)
	else:
		direction = direction_v if direction_v else direction_h
		
	return(direction)


func shoot(direction_vector: Vector2, direction_string: String):
	# We can only shoot once, so skip if we are already shooting
	if (laser_count  >= laser_max):
		print(str("Shot count: ", laser_count, " max: ", laser_max, ", Exiting"))
		return
	print(str("Shot count: ", laser_count, " max: ", laser_max, ", Firing"))
	laser_count +=1
	var laser:Area2D = Laser.instantiate()
	laser.notify_spawner = Callable(self,"remove_laser")
	laser.color = color
	laser.speed = 300
	laser.set_direction(direction_vector, direction_string)
	# Set initial position to robot position,
	# plus a bit along the shot path
	laser.transform = self.global_transform
	laser.position += (direction_vector * 50)
	# Add to the parent, so it doesn't move with us.
	owner.add_child(laser)
	laser.active()


func remove_laser():
	if (laser_count > 0):
		laser_count -=1
	else:
		print("Attempt to remove laser when count is 0")


func kill_robot() -> void:
	# We're dead, we can't collide any more
	set_collision_layer_value(1, false)
	robot_died.emit()
	shoot_timer.stop()
	$DeathSound.play()
	state = "Death"
	direction = ""


func pause_robot():
	self.set_process_mode(Node.PROCESS_MODE_DISABLED)

# Disable robot by stopping processing
# And movving off the playing field
func disable_robot():
	process_mode=Node.PROCESS_MODE_DISABLED
	set_collision_layer_value(1, false)
	shoot_timer.stop()
	position=Vector2i(-5000,-5000)

func init_robot():
	position=start_position
	sprite.set_instance_shader_parameter("new_color", color)
	state="Idle"
	set_collision_layer_value(1, true)
	process_mode=Node.PROCESS_MODE_INHERIT
	laser_count = 0
	shoot_timer.start(randf_range(2,4))

func _on_animated_sprite_2d_animation_finished() -> void:
	match state:
		"Death":
			shoot_timer.stop()
			disable_robot()


func _on_shoot_timer_timeout() -> void:
	var direction_vector = _vector_to_target()
	var direction_string = _direction_vector_to_word(direction_vector, true)
	shoot(direction_vector, direction_string)
	shoot_timer.start(randf_range(1,2.5))

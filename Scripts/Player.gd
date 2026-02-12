extends CharacterBody2D

signal player_died

@export var Laser : PackedScene
# Player speed
@export var speed:int = 150
@export var laser_max: int = 2

var laser_count:int = 0;

@onready var sprite:AnimatedSprite2D = get_node("AnimatedSprite2D")
@onready var death_timer: Timer = get_node("DeathTimer")
@onready var shot_timer: Timer = get_node("ShotTimer")

var direction:String=""
# States: Idle, Walk, Shoot, Death
var state:String="Idle"


func _physics_process(_delta: float) -> void:
	var input_vector:Vector2 = Vector2.ZERO
	# If we are dying, we can't do anything else.
	if (state != "Death"):
		input_vector = process_input()
	if (state == "Shoot" and input_vector != Vector2.ZERO):
		shoot(input_vector)
	if (state == "Walk"):
		var collision = move_and_collide(input_vector * speed * _delta)
		if (collision):
			var collider:CollisionObject2D = collision.get_collider()
			if (collider.is_in_group("Exits")):
				print("Hit Exit!")
			kill_player(collider)

	# Play an animation based on the directions we built, 
	# or if we are dead.
	sprite.play(str(state,direction))

func process_input() -> Vector2:
	var input_vector:Vector2 = Vector2.ZERO
	# We need to know if we are shooting to pick the right Sprite
	if (Input.is_action_pressed("Action-A")):
		state = "Shoot"
	else:
		state = "Idle"

	input_vector.x = Input.get_axis("walk_left", "walk_right")
	input_vector.y = Input.get_axis("walk_up", "walk_down")
	
	# Build sprite word from the direction and state
	# Idle has no direction in Berzerk
	if (input_vector == Vector2.ZERO):
		direction=""
	else:
		#print(str('Vector: (', input_vector.x, ",", input_vector.y,")"))
		# For walking default to Right since we only have 2 animations
		var direction_h: String = "" if (state == "Shoot") else "Right"
		var direction_v: String = ""
		# Set the direction label
		if (input_vector.x<0):
			direction_h="Left"
		elif (input_vector.x>0):
			direction_h="Right"
		if (input_vector.y < 0):
			direction_v="Up"
		elif (input_vector.y > 0):
			direction_v="Down"

		# If a direction is pushed and we aren't shooting, we are walking
		if (state == "Shoot"):
			# Construct direction from vertical & horizontal
			direction = str(direction_v,direction_h)
		else:
			state = "Walk"
			# We only have animations for left and right, do what the arcade does.
			direction = direction_h
	return(input_vector)

func shoot(direction_vector: Vector2):
	# We can only shoot once, so skip if we are already shooting
	if ((laser_count  >= laser_max) or (!shot_timer.is_stopped())):
		return
	# Get the muzzle object for the direcion.
	# If it doesn't exist, use Right
	var muzzle:Marker2D = get_node(str('Muzzle', direction))
	if !is_instance_valid(muzzle):
		muzzle = get_node("MuzzleRight")
	# Create and set up the laser object
	var laser:Area2D = Laser.instantiate()
	laser.notify_spawner = Callable(self,"remove_laser")
	laser.color = Color(0,1,0)
	laser.set_direction(direction_vector, direction)
	laser.position = muzzle.global_position
	# Add to the parent, so it doesn't move with us.
	owner.add_child(laser)
	laser.active()
	laser_count += 1;
	shot_timer.start()


func remove_laser():
	laser_count -= 1


func kill_player(killer:CollisionObject2D) -> void:
	# You only die once, even if they shoot you again.
	print("Player killed by: ", killer)
	if state != "Death":
		state = "Death"
		direction = ""
		death_timer.start()
		#$GotTheIntruder.play()
		$"DeathSound".play()


func _on_death_timer_timeout() -> void:
	death_timer.stop()
	state = "Idle"
	# Restart the game
	player_died.emit()

extends CharacterBody2D

@export var Laser : PackedScene
# Player speed
@export var speed:int = 150

var is_firing : bool = false

@onready var sprite:AnimatedSprite2D = get_node("AnimatedSprite2D")
var direction:String=""
# States: Idle, Walk, Shoot, Death
var state:String="Idle"

#func _ready() -> void:
#	var trigger : Area2D = $"CollisionTrigger"
#	trigger.body_entered.connect( Callable(self,"kill_player"), CONNECT_ONE_SHOT)
#	print("Ready!")
	
func _physics_process(_delta: float) -> void:
	var input_vector:Vector2 = Vector2.ZERO
	# If we are dying, we can't do anything else.
	if (state != "Death"):
		input_vector = process_input()
	if (state == "Shoot" and input_vector != Vector2.ZERO):
		shoot()
	if (state == "Walk"):
		var collision = move_and_collide(input_vector * speed * _delta)
		if (collision):
			kill_player()

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
			print(direction)
		else:
			state = "Walk"
			#velocity = input_vector * speed
			# We only have animations for left and right, do what the arcade does.
			direction = direction_h
	return(input_vector)

func shoot():
	# We can only shoot once, so skip if we are already shooting
	if (is_firing):
		return
	var laser = Laser.instantiate()
	laser.remove_laser = Callable(self,"remove_bullet")
	owner.add_child(laser)
	laser.transform = $Muzzle.global_transform
	is_firing = true;
	
func remove_bullet():
	is_firing = false

func kill_player() -> void:
	state = "Death"
	direction = ""


#func _unhandled_input(_event: InputEvent) -> void:
#		pass

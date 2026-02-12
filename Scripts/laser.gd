extends Area2D

signal laser_fired

var sprite_node:Sprite2D
var collision_node:CollisionShape2D
@onready var sfx_node :AudioStreamPlayer2D = get_node("SFX")
var speed = 700 
var notify_spawner : Callable
var direction_vector: Vector2 
var state: String
var direction: String
var color:Color = Color(0,0,1)
var deg90:float= PI/2

func _ready() -> void:
	sfx_node.play()
	

func _physics_process(_delta: float) -> void:
	if (state == "Active"):
		position += direction_vector * speed * _delta
		

func set_direction(new_direction_vector: Vector2, new_direction: String) -> void:
	direction_vector = new_direction_vector
	direction = new_direction
	# Use the direction string length see if this is straight or diag
	if (direction.length() <6):
		sprite_node = get_node("SpriteStraight")
		collision_node = get_node("CollisionShapeStraight")
		if (direction_vector.y != 0): 
			sprite_node.rotate(deg90)
			collision_node.rotate(deg90)
	else:
		sprite_node = get_node("SpriteDiag")
		collision_node = get_node("CollisionShapeDiag")
		if ((direction =="UpLeft") or (direction =="DownRight")):
			sprite_node.rotate(deg90)
			collision_node.rotate(deg90)
	
	sprite_node.set_instance_shader_parameter("new_color", color)
	sprite_node.visible = true
	collision_node.disabled = false


func active() -> void:
	state = "Active"

func remove_laser() -> void:
	# If the callable has been set, call it to remove the laser count
	# From whatever spawned this shot
	if (notify_spawner != null):
		notify_spawner.call()
	# Set laser to inactive first
	collision_node.disabled = true
	sprite_node.visible = false
	state = "Inactive"
	# If the SFX is still playing, wait for it to finish
	if (sfx_node.playing == true):
		await sfx_node.finished
	# Now delete the object
	queue_free()
	
func _on_body_entered(body: Node2D) -> void:
	# Kill whatever we hit
	if body.is_in_group("Robots"):
		body.kill_robot()
	elif body.is_in_group("Players"):
		body.kill_player()
	
	remove_laser()


func _on_area_entered(_area: Area2D) -> void:
	remove_laser()

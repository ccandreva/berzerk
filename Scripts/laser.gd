extends Area2D

var speed = 700 
var notify_spawner : Callable
var direction_vector: Vector2 
var state: String
var direction: String
var deg90:float= PI/2
func _ready() -> void:
	$SFX.play()

func _physics_process(_delta: float) -> void:
	if (state == "Active"):
		position += direction_vector * speed * _delta
		

func set_direction(new_direction_vector: Vector2, new_direction: String) -> void:
	direction_vector = new_direction_vector
	direction = new_direction
	# Use the direction string length see if this is straight or diag
	if (direction.length() <6):
		$"SpriteStraight".visible = true
		$"CollisionShapeStraight".disabled = false
		if (direction_vector.y != 0): 
			$"SpriteStraight".rotate(deg90)
			$"CollisionShapeStraight".rotate(deg90)
	else:
		$"SpriteDiag".visible = true
		$"CollisionShapeDiag".disabled = false
		if ((direction =="UpLeft") or(direction =="DownRight")):
			$"SpriteDiag".rotate(deg90)
			$"CollisionShapeDiag".rotate(deg90)
				
func active() -> void:
	state = "Active"

func remove_laser() -> void:
	# If the callable has been set, call it to remove the laser count
	# From whatever spawned this shot
	if (notify_spawner != null):
		notify_spawner.call()
	# Remove the laser from the game
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

extends Node2D

signal scroll_finished

@onready var playfield:Node2D = get_node("Playfield")

var speed:int = 400

var playfield_max:Vector2
var corner:Dictionary[String, Vector2]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	playfield_max = playfield.get_max()
	#corner["West"] = Vector2(-playfield_max.x,0)
	#corner["East"] = Vector2(playfield_max.x,0)
	#corner["North"] = Vector2(0,playfield_max.y)
	#corner["South"] = Vector2(0,-playfield_max.y)

# Target corner we are moving the Game Screen too
var target_corner:Vector2
# Vector we compare to for completion check
var initial_vector:Vector2
var state:String = "Idle"

# In the Scrolling state, scroll the Game Screen
func _process(_delta: float) -> void:
	if (state == "Scrolling"):
		var direction_vector:Vector2 = ( target_corner - self.position).normalized()
		# Use a change in the direction vector to indicate we are
		# Close enough to the target to be done.
		if (direction_vector == initial_vector):
			position += (direction_vector * speed * _delta)
		else:
			state = "Idle"
			scroll_finished.emit()

#
# Set scrolling state and target
#
func set_scrolling(vector:Vector2)->void:
	target_corner = playfield_max * vector
	initial_vector = ( target_corner - self.position).normalized()
	state="Scrolling"

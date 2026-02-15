extends Node2D

signal scroll_finished

@onready var playfield:Node2D = get_node("Playfield")
var tween:Tween

var playfield_max:Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set the far corner of the playfield from the marker node
	playfield_max = playfield.get_max()


#
# Set scrolling state and target
#
func set_scrolling(vector:Vector2)->void:
	# Collision shapes must be disabled with set_deferred
	playfield.set_deferred("process_mode",Node.PROCESS_MODE_DISABLED)

	# The target corner we are moving the playfield to
	var target_corner = playfield_max * vector
	# Use a tween to scroll the game_screen off
	tween = create_tween()
	tween.connect("finished", Callable(self, "_on_tween_finished"))
	tween.tween_property(self, "position", target_corner, 2.5)
	return

func _on_tween_finished() -> void:
	# Restart the game
	playfield.process_mode=Node.PROCESS_MODE_INHERIT
	# Tell the main node we are done
	scroll_finished.emit()
	# Reset the playfield back to the origin
	position = Vector2.ZERO

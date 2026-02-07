extends Node2D

@export var playfield : PackedScene
@export var player : PackedScene
@export var robot : PackedScene

var room_x:int = 0
var room_y:int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"Playfield".build(room_x,room_y)
	# Listen to all exits
	get_tree().call_group("Exits","connect", "exit_triggered", 
		Callable(self,"_on_exit_triggered"))
	

func _on_exit_triggered(exit_name: String) ->void:
		print("Main Exit Triggered by ", exit_name)
		match exit_name:
			"ExitWest":
				room_x = room_x - 1
			"ExitEast":
				room_x = room_x + 1
			"ExitSouth":
				room_y = room_y - 1
			"ExitNorth":
				room_y = room_y + 1
		room_x = room_x & 0xff
		room_y = room_y & 0xff
		$"Playfield".build(room_x,room_y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

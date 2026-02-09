extends Node2D

@onready var playfield:Node2D = get_node("Playfield")
@onready var player:CharacterBody2D = get_node("Player")
#@onready var robot: CharacterBody2D = get_node("Robot")
@onready var robots: Node = get_node("Robots")
var robot: Array[CharacterBody2D]
var num_robots : int
var room_x:int = 0
var room_y:int = 0
var last_exit:String = "ExitEast"
var lives:int = 0
var score:int = 0

var player_starts : Dictionary = {
	"ExitEast": Vector2i(103, 407),
	"ExitWest": Vector2i(1000, 407),
	"ExitSouth": Vector2i(535, 40),
	"ExitNorth": Vector2i(535, 727),
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Listen to all exits
	get_tree().call_group("Exits","connect", "exit_triggered", 
		Callable(self,"_on_exit_triggered"))
	player.connect("player_died", Callable(self, "_on_player_died"))
	num_robots = robots.get_child_count()
	for i in num_robots:
		robot.append(robots.get_child(i))
		robot[i].connect("robot_died", Callable(self,"on_robot_died"))
	
	_start_level()


func _start_level() -> void:
	playfield.build(room_x,room_y)
	_reset_characters()


func _reset_characters():
	for i in num_robots:
		robot[i].init_robot()
	player.position = player_starts[last_exit]


func _end_level() -> void:
	for i in num_robots:
		robot[i].disable_robot()


func _on_player_died() -> void:
	#_end_level()
	lives +=1
	print(str("Lives: ", lives))
	_reset_characters()

func _on_robot_died() -> void:
	score += 50
	print(str("Score: ", score))

func _on_exit_triggered(exit_name: String) ->void:
		last_exit = exit_name
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
		_end_level()
		_start_level()

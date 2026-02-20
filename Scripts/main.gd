extends Node2D

signal start_scroll(exit_name:String)

@onready var GameScreen:Node2D = get_node("GameScreen")
@onready var UI:CanvasLayer = get_node("UI")
@onready var playfield:Node2D = get_node("GameScreen/Playfield")
@onready var player:CharacterBody2D = get_node("GameScreen/Playfield/Player")
@onready var robots: Node2D = get_node("GameScreen/Playfield/Robots")
@onready var evil_otto:CharacterBody2D = get_node("GameScreen//Playfield/EvilOtto")
@onready var label_score:Label = get_node("Score")
@onready var label_lives:Label = get_node("Lives")
@onready var label_bonus:Label = get_node("Bonus")
@onready var scroll_timer:Timer = get_node("ScrollTimer")
@onready var menu:BoxContainer = $UI/Menu

var room_x:int = 0
var room_y:int = 0
var lives:int = 3
var score:int = 0
var last_exit:String = "ExitEast"
var state:String = "Playing"

var exits : Dictionary[String, Dictionary] = {
	"ExitWest": {
		"player_start": Vector2i(1000, 407),
		"room_vector": Vector2i(-1,0),
		"entrance": "DoorEast",
	},
	"ExitEast": {
		"player_start": Vector2i(103, 407),
		"room_vector": Vector2i(1,0),
		"entrance": "DoorWest",
	},
	"ExitNorth": {
		"player_start": Vector2i(535, 727),
		"room_vector": Vector2i(0,1),
		"entrance": "DoorSouth",
	},
	"ExitSouth": {
		"player_start": Vector2i(535, 80),
		"room_vector": Vector2i(0,-1),
		"entrance": "DoorNorth",
	},
}

var level:int = 0
var level_max:int
var level_data : Array[Dictionary] = [
	{"color": Color(1,1,0), "speed": 5, "laser_max": 0},
	{"color": Color(1,0,0), "speed": 20, "laser_max": 1},
	{"color": Color(0,0,1), "speed": 25, "laser_max": 2},
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Listen to all exits
	get_tree().call_group("Exits","connect", "exit_triggered", 
		Callable(self,"_on_exit_triggered"))
	
	menu.connect("menu_play", Callable(self,"_on_menu_play"))
	player.connect("player_died", Callable(self, "_on_player_died"))
	robots.connect("robot_count_changed", Callable(self,"_on_robot_count_changed"))
	GameScreen.connect("scroll_finished", Callable(self,"_on_gamescreen_scroll_finished"))
	self.connect("start_scroll", Callable(self,"_start_scroll"))
	# Set level_max from array size. 
	level_max = level_data.size() - 1
	robots.initialize(player)
	evil_otto.player = player
	get_tree().paused = true


func _on_menu_play():
	lives = 3
	GameScreen.visible=true
	UI.visible=false
	get_tree().paused = false
	_reset_characters()
	_start_level()
	
func _show_menu():
	get_tree().paused = true
	UI.visible=true
	# We must grab focus again after the menu has been hidden
	menu.get_child(0).grab_focus()
	GameScreen.visible=false


func _start_level(entrance:String = "") -> void:
	playfield.build(room_x, room_y, entrance)
	_update_lives()
	_reset_characters()

func _update_lives() -> void:
	var display_lives:String = ''
	# Lpad with smiley face which is the man character in custom font
	display_lives = display_lives.lpad(lives-1,'☺')
	label_lives.text = display_lives

func _reset_characters():
	label_bonus.text = ""
	player.init_player(exits[last_exit]["player_start"])
	# Remove any shots currently in the air
	get_tree().call_group("Shots","remove_laser")
	robots.reset(level_data[level])
	evil_otto.init_otto(level_data[level], exits[last_exit]["player_start"])


func _next_level() -> void:
	level +=1
	if (level > level_max):
		level = 0


func _on_player_died() -> void:
	lives -=1
	_update_lives()
	print(str("Lives: ", lives))
	playfield.open_current_entrance()
	_reset_characters()
	if (lives <= 0):
		_show_menu()


func _on_robot_count_changed(is_count_zero:bool) -> void:
	# 50 points per robot
	score += 50
	# If all robots are dead, add a bonus
	if (is_count_zero == true):
		var bonus = (10 * robots.robots_max)
		score += bonus
		label_bonus.text = str("BONUS ", bonus)
		evil_otto.fast()
	label_score.text = str(score)


func _on_exit_triggered(exit_name: String) ->void:
	print("Exited through ", exit_name)
	if (state == "Scrolling"):
		print("Already scrolling, returning.")
	else:
		start_scroll.emit(exit_name)
#		_start_scroll(exit_name)

func _start_scroll(exit_name:String) -> void:
	state = "Scrolling"
	if (robots.robots_live == 0):
		$Insults.play()
	else:
		$Chicken.play()
	last_exit = exit_name
	var room_vector:Vector2i = exits[exit_name]["room_vector"]
	room_x = (room_x + room_vector.x) & 0xff
	room_y = (room_y + room_vector.y) & 0xff
	
	_next_level()
	GameScreen.set_scrolling(room_vector)

func _on_gamescreen_scroll_finished():
	print("Done scrolling, Starting level")
	_start_level(exits[last_exit]["entrance"])
	print("Started, starting timer.")
	scroll_timer.start(0.1)
	print("waiting for timer.")
	await scroll_timer.timeout
	print("Done waiting. Setting state.")
	state = "Playing"
	print("State set")

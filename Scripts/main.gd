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
@onready var scroll_timer:Timer = get_node("ScrollTimer")
@onready var menu:BoxContainer = $UI/Menu

var robot: Array[CharacterBody2D]
var robots_max : int
var robots_live: int
var room_x:int = 0
var room_y:int = 0
var last_exit:String = "ExitEast"
var lives:int = 3
var score:int = 0
var state:String = "Playing"

var player_starts : Dictionary = {
	"ExitEast": Vector2i(103, 407),
	"ExitWest": Vector2i(1000, 407),
	"ExitSouth": Vector2i(535, 40),
	"ExitNorth": Vector2i(535, 727),
}

var room_vectors : Dictionary[String, Vector2i] = {
	"ExitWest": Vector2i(-1,0),
	"ExitEast": Vector2i(1,0),
	"ExitNorth": Vector2i(0,1),
	"ExitSouth": Vector2i(0,-1)
}

var level:int = 0
var level_max = 2
var level_colors : Array[Color] = [ Color(1,1,0), Color(1,0,0), Color(0,0,1)]
var level_speed : Array[int] = [5, 20, 25]
var level_laser_max : Array[int] = [0,1, 2]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Listen to all exits
	get_tree().call_group("Exits","connect", "exit_triggered", 
		Callable(self,"_on_exit_triggered"))
	
	menu.connect("menu_play", Callable(self,"_on_menu_play"))
	player.connect("player_died", Callable(self, "_on_player_died"))
	GameScreen.connect("scroll_finished", Callable(self,"_on_gamescreen_scroll_finished"))
	self.connect("start_scroll", Callable(self,"_start_scroll"))
	robots_max = robots.get_child_count()
	for i in robots_max:
		robot.append(robots.get_child(i))
		robot[i].connect("robot_died", Callable(self,"_on_robot_died"))
		robot[i].player = player
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
	GameScreen.visible=false


func _start_level() -> void:
	playfield.build(room_x,room_y)
	_update_lives()
	_reset_characters()

func _update_lives() -> void:
	var display_lives:String = ''
	# Lpad with smiley face which is the man character in custom font
	display_lives = display_lives.lpad(lives-1,'☺')
	label_lives.text = display_lives

func _reset_characters():
	# Remove any shots currently in the air
	get_tree().call_group("Shots","remove_laser")
	for i in robots_max:
		robot[i].color = level_colors[level]
		robot[i].speed = level_speed[level]
		robot[i].laser_max = level_laser_max[level]
		robot[i].init_robot()
	robots_live = robots_max
	player.init_player(player_starts[last_exit])
	evil_otto.color = level_colors[level]
	evil_otto.speed = level_speed[level]
	evil_otto.init_otto()


func _next_level() -> void:
	level +=1
	if (level > level_max):
		level = 0


func _on_player_died() -> void:
	lives -=1
	_update_lives()
	print(str("Lives: ", lives))
	_reset_characters()
	if (lives <= 0):
		_show_menu()


func _on_robot_died() -> void:
	if robots_live>0:
		score += 50
		robots_live -= 1
		if (robots_live == 0):
			score += (10 * robots_max)
		label_score.text = str(score)
		print(str("robots_live = ",robots_live))
	else:
		print(str("Robot died when robots_live = ",robots_live))


func _on_exit_triggered(exit_name: String) ->void:
	print("Exited through ", exit_name)
	if (state == "Scrolling"):
		print("Already scrolling, returning.")
	else:
		start_scroll.emit(exit_name)
#		_start_scroll(exit_name)

func _start_scroll(exit_name:String) -> void:
	state = "Scrolling"
	if (robots_live == 0):
		$Insults.play()
	else:
		$Chicken.play()
	last_exit = exit_name
	var room_vector:Vector2i = room_vectors[exit_name]
	room_x = (room_x + room_vector.x) & 0xff
	room_y = (room_y + room_vector.y) & 0xff
	
	_next_level()
	GameScreen.set_scrolling(room_vector)

func _on_gamescreen_scroll_finished():
	print("Done scrolling, Starting level")
	_start_level()
	print("Started, starting timer.")
	scroll_timer.start(0.1)
	print("waiting for timer.")
	await scroll_timer.timeout
	print("Done waiting. Setting state.")
	state = "Playing"
	print("State set")

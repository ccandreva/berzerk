extends Node2D

var current_room:int = 0
var current_entrance:String = ""
var quadrants: Array[Vector2]
var start_positions: Array[Vector2]
var num_quadrants: int
var quadrant_size: Vector2 = Vector2(195,244)


# Build the maze room base on initial room coordinagtes
# Maze generator from Berzerk /Frenzy arcade
# For explanation of coode see:
# https://web.archive.org/web/20200403110753/http://www.robotron2084guidebook.com/home/games/berzerk/mazegenerator/code/

func _ready() -> void:
	get_quadrants()

func build(room_x: int, room_y: int, entrance: String = "") -> void:
	# First reset arms for the old current room
	_set_arms(false)
	# bz_seed comes in as the room co-ordinates
	current_room = (room_x << 8) + room_y
	# Now set the arms to the new current room
	_set_arms(true)
	open_current_entrance()
	close_entrance(entrance)
	set_start_positions()
	
func set_start_positions():
	# Place Robots
	for i in range(0,num_quadrants):
		var quadrant:Vector2 = quadrants[i]
		var top_left = Vector2(quadrant.x, quadrant.y - quadrant_size.y)
		start_positions[i] = Vector2(top_left.x+randi_range(15,quadrant_size.x),
			top_left.y+randi_range(15,quadrant_size.y))
		print(start_positions[i])


func open_current_entrance() -> void:
	if (current_entrance):
		print("Opening previous door: ", current_entrance)
		get_node("Doors/" + current_entrance).open()
		current_entrance = ""

func close_entrance(entrance:String) -> void:
	if (entrance):
		print("Blocking entrance: ", entrance)
		get_node("Doors/" + entrance).close()
	current_entrance = entrance

func _set_arms(state:bool):
	var bz_seed = berzerk_calc(current_room)
	for i in range(1,9):
		bz_seed = berzerk_calc(bz_seed)
		bz_seed = berzerk_calc(bz_seed)
		var direction:int = (bz_seed >> 8) & 0b00000011
		var pillar:StaticBody2D = get_node(str("Pillar-", i))
		pillar.set_arm(direction, state)
		
		
func berzerk_calc(bz_seed: int) -> int:
	return ((bz_seed * 7) + 0x3153) & 0xffff

func get_max() -> Vector2:
	return (get_node("SouthEastCorner").position)


#
#  Build an array of the lower-left corner of each box
#
func get_quadrants() -> void:
	var last_y:int = -1
	var max_y = get_max().y
	var q2:Array[Vector2]
	for i in range(1,9):
		var pillar:StaticBody2D = get_node(str("Pillar-", i))
		var p = pillar.position
		if (p.y != last_y):
			last_y = p.y
			quadrants.push_back(Vector2(0,p.y))
			if (i > 4):
				q2.push_back(Vector2(0,max_y))
		quadrants.push_back(p)
		if (i>4):
			q2.push_back(Vector2(p.x,max_y))
	quadrants.append_array(q2)
	num_quadrants = quadrants.size() -1
	start_positions.resize(num_quadrants)
	print(quadrants)

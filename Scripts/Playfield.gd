extends Node2D

var current_room:int = 0

# Build the maze room base on initial room coordinagtes
# Maze generator from Berzerk /Frenzy arcade
# For explanation of coode see:
# https://web.archive.org/web/20200403110753/http://www.robotron2084guidebook.com/home/games/berzerk/mazegenerator/code/

func build(room_x: int, room_y: int) -> void:
	# First reset arms for the old current room
	_set_arms(false)
	# bz_seed comes in as the room co-ordinates
	current_room = (room_x << 8) + room_y
	# Now set the arms to the new current room
	_set_arms(true)
	
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

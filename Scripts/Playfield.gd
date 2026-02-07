extends Node2D

# Build the maze room base on initial room coordinagtes
# Maze generator from Berzerk /Frenzy arcade
# For explanation of coode see:
# https://web.archive.org/web/20200403110753/http://www.robotron2084guidebook.com/home/games/berzerk/mazegenerator/code/

func build(room_x: int, room_y: int) -> void:
	# Seed comes in as the room co-ordinates
	var seed = (room_x << 8) + room_y
	seed = berzerk_calc(seed)
	for i in range(1,9):
		seed = berzerk_calc(seed)
		seed = berzerk_calc(seed)
		var direction:int = (seed >> 8) & 0b00000011
		var pillar:StaticBody2D = get_node(str("Pillar-", i))
		pillar.set_arm(direction)
		
		
func berzerk_calc(seed: int) -> int:
	return ((seed * 7) + 0x3153) & 0xffff

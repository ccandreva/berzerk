extends Node2D

#
# Class to handle robots as a group
#
@onready var playfield:Node2D = $".."
var player: CharacterBody2D
var robot: Array[CharacterBody2D]
var robots_max : int
var robots_live: int
var laser_count:int = 0
var laser_max: int = 0


# Notify the game when the robot count changed,
# And if it was the last robot
signal robot_count_changed(is_last_robot:bool)

func initialize(new_player: CharacterBody2D) -> void:
	player = new_player
	robots_max = get_child_count()
	for i in robots_max:
		robot.append(get_child(i))
		robot[i].connect("robot_died", Callable(self,"_on_robot_died"))
		robot[i].player = player

func reset(level_data: Dictionary) -> void:
	
	robots_live = robots_max
	print("Player position: ", player.position)
	for i in robots_max:
		#If the player is in this quadrant, disable this robot
		var robot_in_player_sector:bool = playfield.vector_in_quadrant(player.position, i)
		var random_kill:bool = (randi_range(1,10) == 7)
		if (robot_in_player_sector or random_kill):
#			print(i,": Has Player")
			robot[i].disable_robot()
			robots_live -= 1
		else:
#			print(i,": No Player")
			robot[i].start_position = playfield.start_positions[i]
			robot[i].color = level_data["color"]
			robot[i].speed = level_data["speed"]
			robot[i].init_robot()
	laser_max = level_data["laser_max"]
	laser_count = 0

func add_laser() -> bool:
	if (laser_count  < laser_max):
		laser_count += 1
		return(true)
	return(false)


func remove_laser():
	if (laser_count > 0):
		laser_count -=1
		return(true)
	print("Attempt to remove laser when count is 0")
	return(false)


func _on_robot_died() -> void:
	if robots_live>0:
#		score += 50
		robots_live -= 1
		robot_count_changed.emit(robots_live == 0)
		print(str("Robots_live = ",robots_live))
#		if (robots_live == 0):
#			var bonus = (10 * robots_max)
#			score += bonus
#			label_bonus.text = str("BONUS ", bonus)
#		label_score.text = str(score)
	else:
		print(str("Robot died when robots_live = ",robots_live))

extends Node2D

#
# Class to handle robots as a group
#

#var player: CharacterBody2D
var robot: Array[CharacterBody2D]
var robots_max : int
var robots_live: int

# Notify the game when the robot count changed,
# And if it was the last robot
signal robot_count_changed(is_last_robot:bool)

func initialize(player: CharacterBody2D) -> void:
	robots_max = get_child_count()
	for i in robots_max:
		robot.append(get_child(i))
		robot[i].connect("robot_died", Callable(self,"_on_robot_died"))
		robot[i].player = player

func reset(level_data: Dictionary) -> void:
	for i in robots_max:
		robot[i].color = level_data["color"]
		robot[i].speed = level_data["speed"]
		robot[i].laser_max = level_data["laser_max"]
		robot[i].init_robot()
	robots_live = robots_max


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

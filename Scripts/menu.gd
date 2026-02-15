extends VBoxContainer

signal menu_play

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Play.grab_focus.call_deferred()


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_play_pressed() -> void:
	menu_play.emit()

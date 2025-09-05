extends Control



func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/level1.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

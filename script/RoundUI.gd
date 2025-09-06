extends CanvasLayer
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_level_1_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/level1.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()

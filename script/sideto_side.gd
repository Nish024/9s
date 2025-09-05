extends Node

@export var move_distance: float = 5.0
@export var move_duration: float = 2.0

var enemy: CharacterBody3D
var tween: Tween
var direction := 1

# Variable to store the enemy's starting position.
var initial_position: Vector3

func start(enemy_ref: CharacterBody3D):
	enemy = enemy_ref
	# Store the global position the enemy was placed at in the editor.
	initial_position = enemy.global_position
	_start_tween()

func _start_tween():
	if tween:
		tween.kill()
	
	tween = enemy.create_tween()
	
	# Calculate the target position relative to the initial position.
	# It moves `move_distance` to the right (direction = 1) or left (direction = -1).
	var target_position = initial_position + Vector3(move_distance * direction, 0, 0)
	
	tween.tween_property(enemy, "global_position", target_position, move_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(_on_tween_finished)

func _on_tween_finished():
	# Flip the direction
	direction *= -1
	# Start the next tween, which will use the new direction to go back
	_start_tween()

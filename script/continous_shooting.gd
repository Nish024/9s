extends Node3D

@export var fire_rate: float = 0.5  # This is the duration of the gap
@export var bullet_scene: PackedScene = preload("res://scene/enemy_bullet.tscn")
@export var bullet_speed: float = 20.0
@export var spread_angle: float = 30.0

var enemy: CharacterBody3D
var timer: Timer = null # Initialize to null to check for its existence

func start(enemy_ref: CharacterBody3D):
	enemy = enemy_ref
	
	# Only create the timer once
	if not is_instance_valid(timer):
		timer = Timer.new()
		add_child(timer)
		timer.wait_time = fire_rate
		timer.timeout.connect(_shoot)
		timer.start()

func _shoot():
	# Make sure the enemy is still valid
	if not is_instance_valid(enemy):
		return
	
	var player = get_tree().get_first_node_in_group("Player")
	if not player:
		return
	
	var dir = (player.global_transform.origin - enemy.global_transform.origin).normalized()
	for i in [-1, 0, 1]:
		var bullet = bullet_scene.instantiate()
		enemy.get_parent().add_child(bullet)

		var angle = deg_to_rad(spread_angle) * i
		var rotated_dir = dir.rotated(Vector3.UP, angle).normalized()

		bullet.global_transform.origin = enemy.global_transform.origin
		bullet.look_at(enemy.global_transform.origin + rotated_dir)
		bullet.velocity = rotated_dir
		bullet.speed = bullet_speed
	
	# Start the timer again for the next shot
	timer.start()

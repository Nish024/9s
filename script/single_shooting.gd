extends Node3D

@export var fire_rate: float = 0.5
@export var purple_bullet_scene: PackedScene = preload("res://scene/enemy_bullet.tscn")
@export var orange_bullet_scene: PackedScene = preload("res://scene/Orangebullet.tscn")
@export var bullet_speed: float = 20.0
@export var spread_angle: float = 30.0

var enemy: CharacterBody3D
var timer: Timer = null
var is_purple_turn: bool = true # Start with purple bullets

func start(enemy_ref: CharacterBody3D):
	enemy = enemy_ref
	
	if not is_instance_valid(timer):
		timer = Timer.new()
		add_child(timer)
		timer.wait_time = fire_rate
		timer.timeout.connect(_shoot)
		timer.start()

# In your continuous shooting component script

func _shoot():
	# Make sure the enemy is still valid
	if not is_instance_valid(enemy):
		return
	
	var player = get_tree().get_first_node_in_group("Player")
	if not player:
		return
	
	var bullet_to_shoot: PackedScene
	
	# Select the bullet scene based on the turn
	if is_purple_turn:
		bullet_to_shoot = purple_bullet_scene
	else:
		bullet_to_shoot = orange_bullet_scene
		
	# Flip the flag for the next shot
	is_purple_turn = not is_purple_turn
	
	var dir = (player.global_transform.origin - enemy.global_transform.origin).normalized()

	# ✅ FIX: Remove the for loop and fire only the center bullet.
	var bullet = bullet_to_shoot.instantiate()
	enemy.get_parent().add_child(bullet)

	# The angle for the center bullet is 0.
	var angle = deg_to_rad(spread_angle) * 0
	var rotated_dir = dir.rotated(Vector3.UP, angle).normalized()

	bullet.global_transform.origin = enemy.global_transform.origin
	bullet.look_at(enemy.global_transform.origin + rotated_dir)
	bullet.velocity = rotated_dir
	bullet.speed = bullet_speed
	
	timer.start()

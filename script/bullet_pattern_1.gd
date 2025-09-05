extends Node3D
@export var fire_rate: float = 0.5
@export var bullet_scene: PackedScene = preload("res://scene/enemy_bullet.tscn")
@export var bullet_scenes:PackedScene = preload("res://scene/Orangebullet.tscn")
@export var bullet_speed: float = 20.0
@export var spread_angle: float = 30.0
@onready var timer: Timer = Timer.new()

var enemy: CharacterBody3D

func start(enemy_ref: CharacterBody3D):
	enemy = enemy_ref
	add_child(timer)
	timer.wait_time = fire_rate
	timer.timeout.connect(_shoot)
	timer.start()

func _shoot():
	var player = get_tree().get_first_node_in_group("Player")
	if not player: return

	var dir = (player.global_transform.origin - enemy.global_transform.origin).normalized()
	for i in [-1,0,1]: # left, center, right
		var bullet = bullet_scene.instantiate()
		enemy.get_parent().add_child(bullet)

		var angle = deg_to_rad(spread_angle) * i
		var rotated_dir = dir.rotated(Vector3.UP, angle).normalized()

		bullet.global_transform.origin = enemy.global_transform.origin
		bullet.look_at(enemy.global_transform.origin + rotated_dir)
		bullet.velocity = rotated_dir
		bullet.speed = bullet_speed

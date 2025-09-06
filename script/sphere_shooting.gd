# sphereShooting.gd
extends Node3D

@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.2

var fire_timer: float = 0.0
var enemy_ref: CharacterBody3D = null

func start(_enemy_ref: CharacterBody3D) -> void:
	print("sphereShooting: start called with enemy_ref =", _enemy_ref)
	enemy_ref = _enemy_ref
	fire_timer = fire_rate

func _process(delta: float) -> void:
	if enemy_ref == null:
		return
	
	fire_timer -= delta
	if fire_timer <= 0.0:
		print("sphereShooting: shooting bullets now")
		shoot_four_directions()
		fire_timer = fire_rate

func shoot_four_directions():
	if bullet_scene == null:
		print("sphereShooting: bullet_scene is null!")
		return
	if enemy_ref == null:
		print("sphereShooting: enemy_ref is null!")
		return
	
	var directions = [
		Vector3(1, 0, 1).normalized(),   # Forward-Right
		Vector3(-1, 0, 1).normalized(),  # Forward-Left
		Vector3(1, 0, -1).normalized(),  # Back-Right
		Vector3(-1, 0, -1).normalized()  # Back-Left
	]
	
	for dir in directions:
		var b = bullet_scene.instantiate()
		print("sphereShooting: bullet instantiated =", b)
		get_tree().current_scene.add_child(b)  # add to scene first

	# Now safe to set position
		b.global_transform.origin = enemy_ref.global_transform.origin
	
		if b.has_method("set_velocity"):
			b.set_velocity(dir)
		b.shooter = enemy_ref
		print("sphereShooting: bullet added to scene")

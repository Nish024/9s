extends Node3D

@export var bullet_purple: PackedScene = preload("res://scene/enemy_bullet.tscn")
@export var fire_rate: float = 2.0

var enemy_ref: Node = null
var bullet_spawn_ref: Marker3D = null # New variable to hold the reference
var can_shoot := true

# Modify the start function to accept the bullet_spawn node
func start(enemy: Node, bullet_spawn_node: Marker3D) -> void:
	enemy_ref = enemy
	bullet_spawn_ref = bullet_spawn_node # Store the reference
	set_process(true)




func _process(_delta: float) -> void:
	if can_shoot and enemy_ref:
		shoot()
		can_shoot = false
		await get_tree().create_timer(fire_rate).timeout
		can_shoot = true

func shoot() -> void:
	if not enemy_ref or not bullet_spawn_ref:
		return

	var origin = bullet_spawn_ref.global_transform.origin
	var dirs = [
		Vector3(1, 0, 1),   # Forward-Right
		Vector3(-1, 0, 1),  # Forward-Left
		Vector3(1, 0, -1),  # Back-Right
		Vector3(-1, 0, -1)  # Back-Left
	]

	for dir in dirs:
		if bullet_purple:
			var b = bullet_purple.instantiate()
			get_tree().current_scene.add_child(b)

			# spawn slightly offset so it doesn’t collide instantly
			b.global_transform.origin = origin + dir.normalized() * 1.0
			
			# assign shooter + velocity
			b.shooter = enemy_ref
			b.set_velocity(dir)

extends Node3D

@export var bullet_scene: PackedScene = preload("res://scene/enemy_bullet.tscn")
@export var fire_rate: float = 1.0

var player_ref: CharacterBody3D = null
var bullet_spawn_ref: RayCast3D = null
var can_shoot: bool = true

func start(player: CharacterBody3D, bullet_spawn_node: RayCast3D) -> void:
	player_ref = player
	bullet_spawn_ref = bullet_spawn_node
	set_process(true) # Make sure this is set to true

func _process(_delta: float) -> void:
	if can_shoot and is_instance_valid(player_ref):
		shoot()
		can_shoot = false
		await get_tree().create_timer(fire_rate).timeout
		can_shoot = true

func shoot() -> void:
	if not is_instance_valid(player_ref) or not is_instance_valid(bullet_spawn_ref):
		return
	
	var bullet_instance = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet_instance)
	bullet_instance.global_position = bullet_spawn_ref.global_position
	
	var shoot_direction = (player_ref.global_position - bullet_spawn_ref.global_position).normalized()
	
	# Assuming your bullet script has a set_velocity method
	shoot_direction *= -1
	
	bullet_instance.set_velocity(shoot_direction * 25.0)

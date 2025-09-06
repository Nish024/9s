extends Node3D

@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.2
@onready var enemy_ref = $Enemy  # Reference to your enemy node

var fire_timer: float = 0.0

func _process(delta: float) -> void:
	fire_timer -= delta
	if fire_timer <= 0.0:
		shoot_four_directions()
		fire_timer = fire_rate

func shoot_four_directions():
	if bullet_scene == null:
		return
	
	var directions = [
		Vector3.LEFT,
		Vector3.RIGHT,
		Vector3.FORWARD,
		Vector3.BACK
	]
	
	for dir in directions:
		var b = bullet_scene.instantiate()
		b.global_transform.origin = enemy_ref.global_transform.origin
		b.set_velocity(dir.normalized() * b.speed)
		b.shooter = enemy_ref
		get_tree().current_scene.add_child(b)

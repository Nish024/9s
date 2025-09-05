extends Area3D

@export var speed: float = 25.0
@export var damage: int = 10
@export var lifetime: float = 5.0

var velocity: Vector3 = Vector3.ZERO
var shooter: Node = null
var last_position: Vector3

func _ready() -> void:
	# Save starting position for raycast checks
	last_position = global_position
	
	# Bullet auto-despawns after 'lifetime' seconds
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

	# Enable collisions one frame later to avoid self-collision
	$CollisionShape3D.disabled = true
	await get_tree().process_frame
	$CollisionShape3D.disabled = false

func set_velocity(dir: Vector3) -> void:
	velocity = dir.normalized()

func _physics_process(delta: float) -> void:
	var space_state = get_world_3d().direct_space_state
	var new_position = global_position + velocity * speed * delta

	# Raycast between last and new position
	var result = space_state.intersect_ray(
		PhysicsRayQueryParameters3D.create(last_position, new_position, collision_mask)
	)

	if result.size() > 0:
		var body = result["collider"]
		if body != shooter:
			if body.has_method("take_damage"):
				body.take_damage(damage)
			call_deferred("queue_free")
			return  # stop movement after hit

	# If no collision, move as usual
	global_position = new_position
	last_position = new_position

func _on_body_entered(body: Node) -> void:
	# Secondary safety (still works for overlapping Area3Ds)
	if body == shooter:
		return
	if body.has_method("take_damage"):
		body.take_damage(damage)
	call_deferred("queue_free")

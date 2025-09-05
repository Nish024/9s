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

	# Prevent collision issues on spawn
	$CollisionShape3D.disabled = true
	await get_tree().process_frame
	$CollisionShape3D.disabled = false

func _physics_process(delta: float) -> void:
	var space_state = get_world_3d().direct_space_state
	var new_position = global_position + velocity * speed * delta

	# ✅ Make sure raycast uses this Area3D's collision_mask
	var query := PhysicsRayQueryParameters3D.create(last_position, new_position)
	query.collision_mask = collision_mask  

	var result = space_state.intersect_ray(query)

	if result.size() > 0:
		var body = result["collider"]

		# Ignore shooter
		if body == shooter:
			pass
		# ✅ If it hits a player bullet → destroy both
		elif body.is_in_group("player_bullet"):
			if body.is_inside_tree():
				body.call_deferred("queue_free")
			call_deferred("queue_free")
			return
		# ✅ If it hits something damageable
		elif body.has_method("take_damage"):
			body.take_damage(damage)
			call_deferred("queue_free")
			return
		# ✅ If it’s a static wall or obstacle
		elif body is StaticBody3D:
			call_deferred("queue_free")
			return

	# If no collision, move bullet forward
	global_position = new_position
	last_position = new_position

func _on_body_entered(body: Node) -> void:
	if body == shooter:
		return
	if body.is_in_group("player_bullet"):
		if body.is_inside_tree():
			body.call_deferred("queue_free")
		call_deferred("queue_free")
	elif body.has_method("take_damage"):
		body.take_damage(damage)
		call_deferred("queue_free")

func set_velocity(dir: Vector3) -> void:
	velocity = dir.normalized()

func _on_area_entered(area: Area3D) -> void:
	if area == self:
		return
	if area.is_in_group("player_bullet"):
		area.queue_free()
		queue_free()
	if area.is_in_group("enemy_bullet"):
		area.queue_free()
		queue_free()

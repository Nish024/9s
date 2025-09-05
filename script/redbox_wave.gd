extends Node3D

@export var damage: int = 10
@export var cooldown: float = 3.0

@onready var damage_area: Area3D = $DamageArea   # your Area3D node

# Block bullets
func _on_damage_area_area_entered(area: Area3D) -> void:
	if area.is_in_group("player_bullet"):
		area.queue_free()

# Player touches hazard
func _on_damage_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage") and damage_area.monitoring:
		_apply_damage(body)

func _apply_damage(body: Node3D) -> void:
	body.take_damage(damage)

	# Disable collisions temporarily
	damage_area.monitoring = false
	damage_area.monitorable = false

	# Reactivate after cooldown
	await get_tree().create_timer(cooldown).timeout
	damage_area.monitoring = true
	damage_area.monitorable = true

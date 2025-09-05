extends Node3D

@export var damage: int = 10
@export var cooldown: float = 3.0

@onready var damage_area: Area3D = $DamageArea
@onready var mesh: MeshInstance3D = $MeshInstance3D

@export var radius: float = 5.0
@export var speed: float = 1.0
var _initial_position: Vector3

func _ready() -> void:
	_initial_position = global_position
	
	# Connect signals only if not already connected
	if not damage_area.area_entered.is_connected(_on_damage_area_area_entered):
		damage_area.area_entered.connect(_on_damage_area_area_entered)

	if not damage_area.body_entered.is_connected(_on_damage_area_body_entered):
		damage_area.body_entered.connect(_on_damage_area_body_entered)

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

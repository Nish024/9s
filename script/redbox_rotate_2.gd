extends StaticBody3D

@export var damage: int = 10
@export var cooldown: float = 3.0

@onready var damage_area: Area3D = $DamageArea
@onready var mesh: MeshInstance3D = $MeshInstance3D

@export var radius: float = 5.0
@export var speed: float = 1.0

var _angle: float = 0.0
@export var _center: Vector3 = Vector3(-11,0.5,-6.0) # Changed x-coordinate to a negative value

func _ready() -> void:
	# Connect bullet collisions
	if not damage_area.area_entered.is_connected(_on_damage_area_area_entered):
		damage_area.area_entered.connect(_on_damage_area_area_entered)

	# Connect player collisions
	if not damage_area.body_entered.is_connected(_on_damage_area_body_entered):
		damage_area.body_entered.connect(_on_damage_area_body_entered)

func _process(delta: float) -> void:
	_angle -= speed * delta # This is the change

	# Orbit around center (XZ plane only)
	var new_x = _center.x + radius * cos(_angle)
	var new_z = _center.z + radius * sin(_angle)
	global_position = Vector3(new_x, global_position.y, new_z)

	# Rotate only on Y axis to face the center (no inclination)
	var dir = _center - global_position
	var angle_y = atan2(dir.x, dir.z)
	rotation = Vector3(0, angle_y, 0)

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

extends CharacterBody3D

@export var health: int = 50
@export var movement_speed: float = 2.5
@export var rotation_speed: float = 2.0
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var square_mesh : MeshInstance3D = $MeshInstance3D/square
@onready var bullet: Node3D = $triangle_bullet
@onready var ray: RayCast3D = $MeshInstance3D/RayCast3D

var bullet_component: Node = null

signal died

var base_color: Color = Color8(0x6e, 0x6e, 0x6e)
var _is_flashing := false
var player_ref: CharacterBody3D = null

func _ready():
	ray.target_position = Vector3(0, 0, 10)
	bullet_component = $triangle_bullet
	if bullet_component and bullet_component.has_method("start"):
		bullet_component.start(self,ray)
	# Find the player node in the scene. Make sure your player node is in the "player" group.
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player_ref = players[0]
	else:
		print("Error: Player not found in 'player' group!")
	
	# Set up the material for the mesh
	if mesh.material_override == null:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = base_color
		mesh.material_override = mat
		square_mesh.material_override = mat
	else:
		mesh.material_override.albedo_color = base_color
		square_mesh.material_override.albedo_color = base_color

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player_ref):
		velocity = Vector3.ZERO
		return

	# --- Movement Towards Player ---
	var direction = (player_ref.global_position - global_position).normalized()
	velocity = direction * movement_speed
	
	# --- Rotation to Face Player ---
	# Calculate the dihrection to the player while keeping on the XZ plane
	var target_direction = (player_ref.global_position - global_position).normalized()
	target_direction.y = 0
	
	if target_direction.length_squared() > 0.001:
		var body_target_transform = global_transform.looking_at(global_position + target_direction, Vector3.UP, true)
		global_transform = global_transform.interpolate_with(body_target_transform, rotation_speed * delta)

	move_and_slide()

func take_damage(amount: int) -> void:
	health -= amount
	flash_damage()
	if health <= 0:
		die()

func flash_damage() -> void:
	# Prevent multiple flash effects from running at the same time
	if _is_flashing:
		return
	
	_is_flashing = true
	
	# Create a temporary white material for the flash
	var flash_mat := StandardMaterial3D.new()
	flash_mat.albedo_color = Color.WHITE
	mesh.material_override = flash_mat
	square_mesh.material_override = flash_mat
	# Wait for a short duration
	await get_tree().create_timer(0.1).timeout
	
	# Restore the mesh's material to the original color
	if is_instance_valid(mesh):
		var mat := StandardMaterial3D.new()
		mat.albedo_color = base_color
		mesh.material_override = mat
		square_mesh.material_override = mat
	
	_is_flashing = false

func die():
	queue_free()
	emit_signal("died")

# Corrected Enemy Main Script
extends CharacterBody3D

@export var health: int = 100
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var movement: Node3D = $SidetoSide 
@onready var bullet: Node3D = $shootatplayer  

var base_color: Color = Color8(0x6e, 0x6e, 0x6e)
var _is_flashing := false
var movement_component: Node = null
var bullet_component: Node = null
var enemy: CharacterBody3D
signal died

# Remove the _ready() function entirely to prevent premature initialization.

# Add a start function that will be called by the WaveSpawner.
func start(_enemy_ref: CharacterBody3D) -> void:
	movement_component = $SidetoSide
	bullet_component = $shootatplayer

	if movement_component and movement_component.has_method("start"):
		print("DEBUG: calling shooting start()")
		movement_component.start(self)
	if bullet_component and bullet_component.has_method("start"):
		print("DEBUG: calling shooting start()")
		bullet_component.start(self)
	# Set up material if missing
	mesh.material_override.albedo_color = base_color
	if mesh.material_override == null:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = base_color
		mesh.material_override = mat

func take_damage(amount: int) -> void:

	health -= amount
	print(health)
	flash_damage()
	if health <= 0:
		die()

func flash_damage() -> void:
	if _is_flashing:
		return
	_is_flashing = true
	
	var mat := mesh.material_override as StandardMaterial3D
	if mat:
		mat.albedo_color = Color.WHITE
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(mesh) and mat:
			mat.albedo_color = base_color
	
	_is_flashing = false

func die():
	queue_free()
	emit_signal("died")

extends Node3D

@export var rotation_speed: float = 45 # degrees per second
var mesh_ref: Node = null # Changed variable name for clarity

func start(mesh_instance: Node) -> void:
	print("start() function in RotateinPlace was called.")
	mesh_ref = mesh_instance # Store the mesh reference
	set_process(true)

func _process(delta: float) -> void:
	if mesh_ref:
		mesh_ref.rotate_y(deg_to_rad(rotation_speed) * delta)

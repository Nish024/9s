extends Area3D

@export var max_health: int = 50
var current_health: int
@onready var mesh: MeshInstance3D = $MeshInstance3D
var _is_flashing := false

# I added an export variable so you can change the starting color in the editor.
@export var start_color: Color = Color("#f5f5dc")

func _ready():
	current_health = max_health
	
	if mesh.material_override is ShaderMaterial:
		# Duplicate the material to avoid sharing state across shields
		mesh.material_override = (mesh.material_override as ShaderMaterial).duplicate()
		var mat = mesh.material_override as ShaderMaterial
		
		# Set starting colors and reset flash
		mat.set_shader_parameter("shield_color", start_color)
		mat.set_shader_parameter("flash_strength", 0.0)


func take_damage(amount: int) -> void:
	current_health -= amount
	flash_damage()
	if current_health <= 0:
		queue_free()

func flash_damage() -> void:
	if _is_flashing:
		return
	_is_flashing = true

	var mat := mesh.material_override as ShaderMaterial
	if mat:
		# Trigger red flash
		mat.set_shader_parameter("flash_strength", 1.0)

		await get_tree().create_timer(0.1).timeout

		# Reset flash
		if is_instance_valid(mesh) and mat:
			mat.set_shader_parameter("flash_strength", 0.0)

	_is_flashing = false

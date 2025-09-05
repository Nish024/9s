extends Node3D

# --- Properties ---
@export var health: int = 100
@onready var mesh: MeshInstance3D = $MeshInstance3D
@export var fire_rate: float = 0.5
@export var bullet_scene: PackedScene = preload("res://scene/enemy_bullet.tscn")
@export var bullet_speed: float = 20.0
@export var spread_angle: float = 30.0
@onready var timer: Timer = $Timer
var base_color: Color = Color8(0x6e, 0x6e, 0x6e)
var _is_flashing := false
var movement_component: Node = null
var bullet_component: Node = null
# --- State ---
var enemy: CharacterBody3D
signal died
# This function is called once by the enemy's main script
# to initialize the shooting component.
func start(enemy_ref: CharacterBody3D):
	enemy = enemy_ref
	bullet_component = $Continous_shooting
	if bullet_component and bullet_component.has_method("start"):
		print("DEBUG: calling shooting start()")
		bullet_component.start(self)
	if not timer:
		timer = Timer.new()
		add_child(timer)
		timer.wait_time = fire_rate
		timer.timeout.connect(_shoot)
		timer.start()

func _shoot():
	# This function will be called by the timer.
	# We should first ensure the enemy and a player exist before shooting.
	if not is_instance_valid(enemy):
		return
	
	var player = get_tree().get_first_node_in_group("Player")
	if not player:
		return
	
	# Your existing shooting logic
	var dir = (player.global_transform.origin - enemy.global_transform.origin).normalized()
	for i in [-1, 0, 1]:
		var bullet = bullet_scene.instantiate()
		enemy.get_parent().add_child(bullet)

		var angle = deg_to_rad(spread_angle) * i
		var rotated_dir = dir.rotated(Vector3.UP, angle).normalized()

		bullet.global_transform.origin = enemy.global_transform.origin
		bullet.look_at(enemy.global_transform.origin + rotated_dir)
		bullet.velocity = rotated_dir
		bullet.speed = bullet_speed
	
	# The key is to start the timer again after each shot.
	timer.start()
	
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

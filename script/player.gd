extends CharacterBody3D

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var camera: Camera3D = $Camera3D
@onready var player_ray: RayCast3D = $MeshInstance3D/RayCast3D
@onready var bullet: PackedScene = preload("res://scene/player_bullet.tscn")
@onready var timer: Timer = $Timer
@onready var health_bar: ProgressBar = $HealthBar


var default_color := Color(1, 1, 1)
var is_holding_fire = false
var instance
const SPEED = 30
var static_camera_transform: Transform3D
var health = 100

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	static_camera_transform = camera.global_transform
	if mesh.material_override and mesh.material_override is StandardMaterial3D:
		default_color = mesh.material_override.albedo_color
	else:
		print("⚠️ Material override not set correctly.")
	update_health_bar()

func _on_health_depleted():
	get_parent().on_player_died()

func _physics_process(delta: float) -> void:
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider.is_in_group("Hazard") and  collider.is_in_group("hazard"):
			take_damage(10)
			flash_red()

	if Input.is_action_pressed("shoot"):
		if !is_holding_fire:
			is_holding_fire = true
			shoot_bullet()
			timer.start()
	else:
		if is_holding_fire:
			is_holding_fire = false
			timer.stop()
	
	rotate_towards_camera()
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir := Input.get_vector("right", "left", "down", "up")
	var direction := Vector3(input_dir.x, 0, input_dir.y).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
func update_health_bar() -> void:
	if health_bar:   # safety check in case it's not ready yet
		health_bar.value = health
	
func take_damage(amount: int) -> void:
	health -= amount
	health = clamp(health, 0, 100)
	update_health_bar()   # ✅ keeps UI in sync
	flash_red()
	if health <= 0:
		die()

func die():
	set_physics_process(false)
	hide()
	mesh.material_override.albedo_color = default_color
	call_deferred("_go_to_menu")

func _go_to_menu():
	get_tree().call_deferred("change_scene_to_file", "res://scene/menu.tscn")

func flash_red():
	if mesh.material_override and mesh.material_override is StandardMaterial3D:
		mesh.material_override.albedo_color = Color(1,0,0)
		await get_tree().create_timer(0.2).timeout
		mesh.material_override.albedo_color = default_color

func rotate_towards_camera():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_direction = camera.project_ray_normal(mouse_pos)
	var ground_y = global_position.y
	var distance = (ground_y - ray_origin.y) / ray_direction.y
	var target_pos = ray_origin + ray_direction * distance
	var direction = (target_pos - global_transform.origin).normalized()
	direction.y = 0

	if direction.length() > 0.001:
		var angle = atan2(direction.x, direction.z)
		mesh.rotation_degrees.y = rad_to_deg(angle)

func _on_timer_timeout() -> void:
	if is_holding_fire:
		shoot_bullet()
	
func shoot_bullet():
	instance = bullet.instantiate()
	instance.global_transform = player_ray.global_transform
	instance.shooter = self
	get_parent().add_child(instance)

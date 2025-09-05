extends CharacterBody3D
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var camera: Camera3D = $Camera3D
@onready var player_ray: RayCast3D = $MeshInstance3D/RayCast3D
@onready var bullet : PackedScene = preload("res://scene/player_bullet.tscn")
var default_color := Color(1, 1, 1)
@onready var timer: Timer = $Timer
var is_holding_fire = false
var instance
const SPEED = 30
var health = 100


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	if mesh.material_override and mesh.material_override is StandardMaterial3D:
		default_color = mesh.material_override.albedo_color
	else:
		print("⚠️ Material override not set correctly.")

func _on_health_depleted():
	get_parent().on_player_died()

func _physics_process(delta: float) -> void:
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.is_in_group("hazard"):  # put your box in "hazard" group
			take_damage(10)
			flash_red()
	if Input.is_action_pressed("shoot"):
		if !is_holding_fire:
			is_holding_fire = true
			shoot_bullet()
			timer.start()
	else:
		# Stop firing when shift is released
		if is_holding_fire:
			is_holding_fire = false
			timer.stop()
	
	rotate_towards_camera()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("right", "left", "down", "up")
	var direction := Vector3(input_dir.x, 0, input_dir.y).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	

func take_damage(amount: int) -> void:
	health -= amount
	print("player health",health)
	flash_red()
	if health <= 0:
		call_deferred("die")
		

func die():
	queue_free()
	hide()
	set_physics_process(false)
	get_tree().change_scene_to_file("res://scene/menu.tscn")
	mesh.material_override.albedo_color = default_color
	# Put sound herea
	# Example: $HitSound.play() if you have an AudioStreamPlayer3D
func flash_red():
	if mesh.material_override and mesh.material_override is StandardMaterial3D:
		mesh.material_override.albedo_color = Color(1,0,0)
		await get_tree().create_timer(0.2).timeout
		mesh.material_override.albedo_color = default_color

func rotate_towards_camera():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_direction =  camera.project_ray_normal(mouse_pos)
	# Calculate where the ray hits ground (Y = player's Y)
	var ground_y = global_position.y
	var distance = (ground_y - ray_origin.y) / ray_direction.y
	var target_pos = ray_origin + ray_direction * distance

	# (same raycasting logic)
	var direction = (target_pos - global_transform.origin).normalized()
	direction.y = 0

	if direction.length() > 0.001:
		var angle = atan2(direction.x, direction.z)#gives the angle in radians between the player’s forward direction
		mesh.rotation_degrees.y = rad_to_deg(angle)

func _on_timer_timeout() -> void:
	if is_holding_fire:
		shoot_bullet()
	
func shoot_bullet():
	instance = bullet.instantiate()
	instance.global_transform = player_ray.global_transform
	instance.shooter = self
	get_parent().add_child(instance)
	

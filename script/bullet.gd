extends Area3D

@export var speed: float = 25.0
@export var damage: int = 10
@export var lifetime: float = 3.0   # bullet auto-despawn after 3 seconds

var shooter: Node = null

@onready var hit_sound: AudioStreamPlayer3D = $HitSound

func _ready() -> void:
	# Auto remove bullet after lifetime
	await get_tree().create_timer(lifetime).timeout
	if is_inside_tree():
		queue_free()

func _physics_process(delta: float) -> void:
	# Move bullet forward in local -Z direction
	translate(Vector3(0, 0, -speed * delta))

func _on_body_entered(body: Node3D) -> void:
	if not is_inside_tree() or not body.is_inside_tree():
		return

	# Ignore hitting the shooter itself
	if body == shooter:
		return

	# Apply damage only if body can take damage
	if body.has_method("take_damage"):
		body.take_damage(damage)

	# Play hit sound as a separate one-shot
	_play_hit_sound()

	# Remove bullet after hit
	call_deferred("queue_free")
	
func _on_area_entered(area: Area3D) -> void:
	if area == shooter: return
	if area.has_method("take_damage"):
		area.take_damage(damage)
	_play_hit_sound()
	call_deferred("queue_free")

func _play_hit_sound() -> void:
	if not hit_sound or not hit_sound.stream:
		return
	
	var temp_sound := AudioStreamPlayer3D.new()
	temp_sound.stream = hit_sound.stream
	temp_sound.global_transform = global_transform

	if get_tree() and get_tree().current_scene:
		get_tree().current_scene.add_child(temp_sound)

	temp_sound.play()
	temp_sound.finished.connect(temp_sound.queue_free)

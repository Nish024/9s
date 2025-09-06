extends Node3D

# --- Wave Configuration ---
@export var enemy_scene: PackedScene
@export var enemy_count: int = 1
@export var spawn_delay: float = 0.0
@export var wave_token: int = 1

# --- Signals ---
signal wave_finished

# --- State Variables ---
var enemies_left_to_spawn: int = 0
var enemies_alive: int = 0

# --- Core Functions ---
func start_wave() -> void:
	enemies_left_to_spawn = enemy_count
	
	if enemies_left_to_spawn > 0:
		_spawn_enemies()
	else:
		wave_finished.emit()

func _spawn_enemies() -> void:
	for i in range(enemy_count):
		_spawn_single_enemy()

func _spawn_single_enemy() -> void:
	print("DEBUG: Attempting to spawn a single enemy.")
	if not enemy_scene:
		print("Error: enemy_scene is not set in the inspector!")
		return
		
	var new_enemy: Node3D = enemy_scene.instantiate()
	get_parent().add_child(new_enemy)
	new_enemy.global_position = self.global_position
	
	# 👇 Mark as temporary wave object
	new_enemy.add_to_group("wave_temp")

	if not (new_enemy is StaticBody3D):
		if new_enemy.has_signal("died"):
			new_enemy.connect("died", _on_enemy_died)
		if new_enemy.has_method("start"):
			new_enemy.start(new_enemy)
		enemies_alive += 1
		print("DEBUG: Spawned new enemy. Enemies alive: ", enemies_alive)

	enemies_left_to_spawn -= 1

func _on_enemy_died() -> void:
	enemies_alive -= 1
	print(self.name, ": Enemies remaining: ", enemies_alive)
	
	if enemies_left_to_spawn <= 0 and enemies_alive <= 0:
		wave_finished.emit()
		
func is_wave_done() -> bool:
	return enemies_left_to_spawn <= 0 and enemies_alive <= 0

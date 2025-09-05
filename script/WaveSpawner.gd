extends Node3D

# --- Wave Configuration ---
# The enemy scene to spawn.
@export var enemy_scene: PackedScene
# The number of enemies to spawn in this wave.
@export var enemy_count: int = 1
# The time in seconds between each enemy spawn.
@export var spawn_delay: float = 0.0
# The token that defines which wave this spawner belongs to.
@export var wave_token: int = 1

# --- Signals ---
# This signal tells the level manager when this wave is complete.
signal wave_finished

# --- State Variables ---
var enemies_left_to_spawn: int = 0
var enemies_alive: int = 0

# --- Core Functions ---
# This function is called by the Level Manager to start this wave.
func start_wave() -> void:
	enemies_left_to_spawn = enemy_count
	
	if enemies_left_to_spawn > 0:
		_spawn_enemies()
	else:
		# If enemy_count is 0, emit the finished signal immediately.
		wave_finished.emit()

# A private function that spawns enemies all at once.
func _spawn_enemies() -> void:
	for i in range(enemy_count):
		_spawn_single_enemy()

# Instantiates and places a single enemy.
func _spawn_single_enemy() -> void:
	print("DEBUG: Attempting to spawn a single enemy.")
	if not enemy_scene:
		print("Error: enemy_scene is not set in the inspector!")
		return
		
	var new_enemy: Node3D = enemy_scene.instantiate()
	
	if new_enemy is StaticBody3D:
		# For a static body, just set the position and add to the scene
		get_parent().add_child(new_enemy)
		new_enemy.global_position = self.global_position
		print("spawned staticbody3d")
	else:
		# For other enemy types, connect signals and call 'start()'
		if new_enemy.has_signal("died"):
			new_enemy.connect("died", _on_enemy_died)
		
		get_parent().add_child(new_enemy)
		new_enemy.global_position = self.global_position

		if new_enemy.has_method("start"):
			new_enemy.start(new_enemy)

		enemies_alive += 1
		print("DEBUG: Spawned new enemy. Enemies alive: ", enemies_alive)

	enemies_left_to_spawn -= 1

# This function is called every time an enemy from this wave is defeated.
func _on_enemy_died() -> void:
	enemies_alive -= 1
	print(self.name, ": Enemies remaining: ", enemies_alive)
	
	# If all enemies have been spawned AND all are now defeated, the wave is over.
	if enemies_left_to_spawn <= 0 and enemies_alive <= 0:
		wave_finished.emit()
		
func is_wave_done() -> bool:
	return enemies_left_to_spawn <= 0 and enemies_alive <= 0
	

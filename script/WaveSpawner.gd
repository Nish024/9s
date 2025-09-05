extends Node3D

# --- Wave Configuration ---
# The time in seconds between each enemy spawn.
@export var spawn_delay: float = 0.0
# The token that defines which wave this spawner belongs to.
@export var wave_token: int = 1
# An array of packed scenes to spawn for this wave.
@export var spawn_list: Array[PackedScene]

# --- Signals ---
# This signal tells the level manager when this wave is complete.
signal wave_finished

# --- State Variables ---
var enemies_alive: int = 0
var enemies_to_spawn: int = 0

# --- Core Functions ---
# This function is called by the Level Manager to start this wave.
func start_wave() -> void:
	enemies_alive = 0
	enemies_to_spawn = spawn_list.size()
	
	if enemies_to_spawn > 0:
		_spawn_enemies()
	else:
		# If there are no enemies to spawn, emit the finished signal immediately.
		wave_finished.emit()

# A private function that spawns nodes from the spawn_list one by one.
func _spawn_enemies() -> void:
	for scene in spawn_list:
		var new_node: Node3D = scene.instantiate()
		
		# Add the new node to the scene tree immediately.
		get_parent().add_child(new_node)
		new_node.global_position = self.global_position
		
		# Call the node's start method if it has one.
		if new_node.has_method("start"):
			new_node.start(new_node)
		
		# Check if the node is an enemy and should be tracked.
		if not new_node.is_in_group("not_enemy") and new_node.has_signal("died"):
			new_node.connect("died", _on_enemy_died)
			enemies_alive += 1
		else:
			# If it's not an enemy, don't track it.
			enemies_to_spawn -= 1
		
		print("DEBUG: Spawned node from list. Remaining to spawn: ", enemies_to_spawn)
		await get_tree().create_timer(spawn_delay).timeout
		
	print("Finished spawning all nodes for wave ", self.name)
	
	# If enemies_alive is 0 after spawning, emit the signal immediately.
	if enemies_alive == 0:
		wave_finished.emit()


# This function is called every time a tracked enemy from this wave is defeated.
func _on_enemy_died() -> void:
	enemies_alive -= 1
	print(self.name, ": Enemies remaining: ", enemies_alive)
	
	# If all enemies have been defeated, the wave is over.
	if enemies_alive <= 0:
		wave_finished.emit()

# This function is used to check the wave status from the level manager.
func is_wave_done() -> bool:
	return enemies_alive <= 0 and enemies_to_spawn <= 0

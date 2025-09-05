extends Node

# Dictionary to store the state of each level.
# "tokens_collected" tracks items collected.
# "completed" indicates if the level is finished.
# "current_wave" tracks the wave number the player is on.
var level_states = {
	"Level1": {"tokens_collected": 0, "completed": false, "current_wave": 0}
}

# The name of the current level scene.
var current_level_name = "Level1"

# Track active spawners for the current wave
var active_spawners_for_wave: Array = []
var enemies_left_to_spawn: int = 0
var enemies_alive: int = 0
# --- Public Functions ---

# Function to start the level.
func start_level(level_name: String) -> void:
	if not level_states.has(level_name):
		print("Error: Level not found - " + level_name)
		return
	
	print("Starting level: " + level_name)
	current_level_name = level_name
	print("Level started: " + current_level_name)
	
	# Begin the wave spawning process for the level.
	start_next_wave()


# Function to advance to the next wave in the current level.
func start_next_wave() -> void:
	# Increment the current wave count for the level.
	level_states[current_level_name]["current_wave"] += 1
	var wave_token = level_states[current_level_name]["current_wave"]
	
	print("Starting Wave " + str(wave_token) + " in " + current_level_name)
	active_spawners_for_wave.clear()
	
	# ✅ Move the player to the desired position before spawning new enemies.
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.global_position = Vector3(-0.7, 0.5, -15.0)
		print("DEBUG: Player moved to new wave spawn point.")

	# ✅ Fixed find_children call
	var all_spawners = get_tree().get_current_scene().find_children("WaveSpawner*", "", true, false)
	var spawners_found = false
	
	for spawner in all_spawners:
		if spawner.has_method("start_wave") and spawner.wave_token == wave_token:
			spawners_found = true
			active_spawners_for_wave.append(spawner)
			# Connect only once to avoid duplicate signals
			if not spawner.wave_finished.is_connected(Callable(self, "_on_wave_finished")):
				spawner.wave_finished.connect(Callable(self, "_on_wave_finished"))
			spawner.start_wave()
	
	if not spawners_found:
		# If no more wave spawners are found, the level is complete.
		complete_level(current_level_name)


# Function to collect a token within the current level.
func collect_token() -> void:
	if level_states.has(current_level_name):
		level_states[current_level_name]["tokens_collected"] += 1
		print("Token collected in " + current_level_name + 
			". Total: " + str(level_states[current_level_name]["tokens_collected"]))



# Function to get the number of tokens collected for a specific level.
func get_tokens_for_level(level_name: String) -> int:
	if level_states.has(level_name):
		return level_states[level_name]["tokens_collected"]
	return 0


# Function to mark a level as completed.
func complete_level(level_name: String) -> void:
	if level_states.has(level_name):
		level_states[current_level_name]["completed"] = true
		print(level_name + " has been completed!")


# --- Private Functions ---

# This function is called when a wave has finished.
func _on_wave_finished() -> void:
	print("A wave spawner finished. Checking if all spawners for this wave are complete...")
	
	var all_spawners_are_finished = true
	# Iterate over the list to check if all spawners are done
	for spawner in active_spawners_for_wave:
		if not spawner.is_wave_done():
			all_spawners_are_finished = false
			break
	
	if all_spawners_are_finished:
		print("All spawners for this wave are finished! Starting next wave...")
		start_next_wave()

func is_wave_done() -> bool:
	return enemies_left_to_spawn <= 0 and enemies_alive <= 0

# _ready() is called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_level("Level1")

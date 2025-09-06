extends Node
@onready var player: CharacterBody3D = $player

var level_states = {
	"Level1": {"tokens_collected": 0, "completed": false, "current_wave": 0}
}

var current_level_name = "Level1"
var active_spawners_for_wave: Array = []
var enemies_left_to_spawn: int = 0
var enemies_alive: int = 0

# --- Public Functions ---
func start_level(level_name: String) -> void:
	if not level_states.has(level_name):
		print("Error: Level not found - " + level_name)
		return
	
	print("Starting level: " + level_name)
	current_level_name = level_name
	start_next_wave()

func start_next_wave() -> void:
	level_states[current_level_name]["current_wave"] += 1
	var wave_token = level_states[current_level_name]["current_wave"]
	
	print("Starting Wave " + str(wave_token) + " in " + current_level_name)
	active_spawners_for_wave.clear()
	
	if player:
		player.global_position = Vector3(-0.7, 0.5, -15.0)

	var all_spawners = get_tree().get_current_scene().find_children("WaveSpawner*", "", true, false)
	var spawners_found = false
	
	for spawner in all_spawners:
		if spawner.has_method("start_wave") and spawner.wave_token == wave_token:
			spawners_found = true
			active_spawners_for_wave.append(spawner)
			if not spawner.wave_finished.is_connected(Callable(self, "_on_wave_finished")):
				spawner.wave_finished.connect(Callable(self, "_on_wave_finished"))
			spawner.start_wave()
	
	if not spawners_found:
		complete_level(current_level_name)

func collect_token() -> void:
	if level_states.has(current_level_name):
		level_states[current_level_name]["tokens_collected"] += 1
		print("Token collected in " + current_level_name + 
			". Total: " + str(level_states[current_level_name]["tokens_collected"]))

func get_tokens_for_level(level_name: String) -> int:
	if level_states.has(level_name):
		return level_states[level_name]["tokens_collected"]
	return 0

func complete_level(level_name: String) -> void:
	if level_states.has(level_name):
		level_states[current_level_name]["completed"] = true
		print(level_name + " has been completed!")

# --- Private Functions ---
func _on_wave_finished() -> void:
	print("A wave spawner finished. Checking if all spawners for this wave are complete...")

	var all_spawners_are_finished = true
	for spawner in active_spawners_for_wave:
		if not spawner.is_wave_done():
			all_spawners_are_finished = false
			break

	if all_spawners_are_finished:
		# 🧹 Cleanup only wave-spawned props/enemies
		for node in get_tree().get_nodes_in_group("wave_temp"):
			if is_instance_valid(node):
				node.queue_free()

		print("All spawners for this wave are finished! Starting next wave...")

		# --- Reset player health to 100 ---
		if player:
			player.health = 100
			print("DEBUG: Player health reset to 100.")

		start_next_wave()


func is_wave_done() -> bool:
	return enemies_left_to_spawn <= 0 and enemies_alive <= 0

func _ready() -> void:
	start_level("Level1")

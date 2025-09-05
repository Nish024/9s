extends Area3D

@export var max_health: int = 50
var current_health: int

func _ready():
	current_health = max_health

func take_damage(amount: int) -> void:
	current_health -= amount
	if current_health <= 0:
		queue_free()

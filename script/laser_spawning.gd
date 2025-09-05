extends Node3D
@onready var mesh: MeshInstance3D = $MeshInstance3D

var target_scale_y: float = 1.0
var animation_speed: float = 2.0
var has_spawned_enemy: bool = false

func _ready():
	# Start with a very small scale
	scale.y = 0.0
	
func _process(delta: float):
	# Interpolate the scale towards the target
	scale.y = lerp(scale.y, target_scale_y, delta * animation_speed)
	

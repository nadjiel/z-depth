extends Node

@onready var sprite: Sprite2D = $Sprite

var distance: float = 0.0:
	set = set_distance

@export var distance_to_disappear: float = 80.0

func set_distance(new_distance: float) -> void:
	distance = new_distance
	
	var min_frame: int = 0
	var max_frame: int = sprite.hframes - 1
	
	sprite.frame = clampi(
		floori((distance * max_frame) / distance_to_disappear),
		min_frame,
		max_frame
	)

extends Node2D

func adequate_to_direction(direction: Vector2) -> void:
	if direction == Vector2.LEFT:
		scale.x = -1
	else:
		scale.x = 1

func adequate_to_z(z: float) -> void:
	position.y = -z

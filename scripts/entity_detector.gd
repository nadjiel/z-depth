
class_name EntityDetector
extends Area2D

const MIN_FLOOR: int = 1

const MAX_FLOOR: int = 4

@export var entity: Entity

var overlapping_entities := DictSet.new()

func _ready() -> void:
	entity.floor_changed.connect(_on_entity_floor_changed)
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	overlapping_entities.updated.connect(_on_overlapping_entities_updated)

func reset_floors_collision() -> void:
	for i: int in range(MIN_FLOOR, MAX_FLOOR + 1):
		set_collision_layer_value(i, false)
		set_collision_mask_value(i, false)

func set_floor_collision(floor_number: int) -> void:
	set_collision_layer_value(floor_number, true)
	set_collision_mask_value(floor_number, true)
	
	monitoring = false
	monitoring = true

func _on_entity_floor_changed(floor_number: int) -> void:
	reset_floors_collision()
	set_floor_collision(floor_number)

func _on_overlapping_entities_updated(
	old_entities: DictSet,
	new_entities: DictSet
) -> void:
	for entity in old_entities.get_as_array():
		entity.modulate = Color.WHITE
	for entity in new_entities.get_as_array():
		entity.modulate = Color.RED

func _on_area_entered(area: Area2D) -> void:
	if area is EntityDetector:
		overlapping_entities.set_element(area.entity)

func _on_area_exited(area: Area2D) -> void:
	if area is EntityDetector:
		overlapping_entities.remove_element(area.entity)

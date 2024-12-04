
class_name EntityDetector
extends Area2D

var overlapping_entities := DictSet.new()

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	overlapping_entities.updated.connect(_on_overlapping_entities_updated)

func _on_entity_floor_changed(floor_number: int) -> void:
	#reset_floors_collision()
	#set_floor_collision(floor_number)
	pass

func _on_overlapping_entities_updated(
	old_entities: DictSet,
	new_entities: DictSet
) -> void:
	for entity in old_entities.get_as_array():
		entity.modulate = Color.WHITE
	for entity in new_entities.get_as_array():
		entity.modulate = Color.RED

func _on_area_entered(area: Area2D) -> void:
	if area is EntityDetectable:
		overlapping_entities.set_element(area.entity)

func _on_area_exited(area: Area2D) -> void:
	if area is EntityDetectable:
		overlapping_entities.remove_element(area.entity)

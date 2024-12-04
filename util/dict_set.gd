
class_name DictSet
extends RefCounted

signal updated(old: DictSet, new: DictSet)

var elements: Dictionary = {}

func set_element(element: Variant) -> void:
	var old_set: DictSet = self.copy()
	
	var had_element: bool = has_element(element)
	
	elements[element] = true
	
	if not had_element:
		updated.emit(old_set, self)

func set_elements(elements: Array) -> void:
	for element: Variant in elements:
		set_element(element)

func has_element(element: Variant) -> bool:
	return elements.has(element)

func remove_element(element: Variant) -> bool:
	var old_set: DictSet = self.copy()
	
	var had_element: bool = has_element(element)
	
	elements.erase(element)
	
	if had_element:
		updated.emit(old_set, self)
	
	return had_element

func get_as_array() -> Array:
	return elements.keys()

func copy() -> DictSet:
	var result := DictSet.new()
	
	for element: Variant in get_as_array():
		result.set_element(element)
	
	return result

func union(other_set: DictSet) -> DictSet:
	var result: DictSet = self.copy()
	
	for element: Variant in other_set.get_as_array():
		result.set_element(element)
	
	return result

func difference(other_set: DictSet) -> DictSet:
	var result := DictSet.new()
	
	for element: Variant in get_as_array():
		if other_set.has_element(element):
			continue
		
		result.set_element(element)
	
	return result

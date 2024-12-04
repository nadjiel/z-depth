
class_name GroundZDetector
extends Node

signal ground_z_changed(new_z: int)

@export var tile_detector: TileDetector

var ground_z: int = 0:
	set = set_ground_z

func set_ground_z(new_z: int) -> void:
	var old_z: float = ground_z
	
	ground_z = new_z
	
	if old_z != new_z:
		ground_z_changed.emit(new_z)

func _ready() -> void:
	tile_detector.tiles_changed.connect(_on_tiles_changed)

func _on_tiles_changed(new_tiles: DictSet) -> void:
	ground_z = 0
	
	for tile: Dictionary in new_tiles.get_as_array():
		var tile_z: int = tile_detector.get_tile_data_layer(
			tile["tile_rid"],
			tile["tile_map"],
			"Height"
		)
		
		if tile_z > ground_z:
			ground_z = tile_z


class_name TileDetector
extends Area2D

signal tiles_changed(new_tiles: DictSet)

var overlapping_tiles := DictSet.new()

func on_tile_entered(tile_rid: RID, tile_map: TileMapLayer) -> void:
	overlapping_tiles.set_element({
		"tile_map": tile_map,
		"tile_rid": tile_rid
	})

func on_tile_exited(tile_rid: RID, tile_map: TileMapLayer) -> void:
	overlapping_tiles.remove_element({
		"tile_map": tile_map,
		"tile_rid": tile_rid
	})

func get_tile_data(tile_rid: RID, tile_map: TileMapLayer) -> TileData:
	var tile_coords: Vector2i = tile_map.get_coords_for_body_rid(tile_rid)
	var tile_data: TileData = tile_map.get_cell_tile_data(tile_coords)
	
	return tile_data

func get_tile_data_layer(
	tile_rid: RID,
	tile_map: TileMapLayer,
	layer_name: String
) -> Variant:
	var tile_data: TileData = get_tile_data(tile_rid, tile_map)
	
	if tile_data == null:
		return null
	
	return tile_data.get_custom_data(layer_name)

func _ready() -> void:
	body_shape_entered.connect(_on_body_shape_entered)
	body_shape_exited.connect(_on_body_shape_exited)
	overlapping_tiles.updated.connect(_on_overlapping_tiles_updated)

func _on_body_shape_entered(body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body is TileMapLayer:
		on_tile_entered(body_rid, body as TileMapLayer)

func _on_body_shape_exited(body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body is TileMapLayer:
		on_tile_exited(body_rid, body as TileMapLayer)

func _on_overlapping_tiles_updated(
	old_tiles: DictSet,
	new_tiles: DictSet
) -> void:
	tiles_changed.emit(overlapping_tiles)

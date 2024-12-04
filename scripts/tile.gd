
class_name Tile
extends RefCounted

var rid: RID

var tile_map_layer: TileMapLayer

func _init(
	tile_map_layer: TileMapLayer,
	rid: RID
) -> void:
	self.tile_map_layer = tile_map_layer
	self.rid = rid

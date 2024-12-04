
class_name Entity
extends CharacterBody2D

const TILE_SIZE: int = 16

const MIN_FLOOR: int = 1

const MAX_FLOOR: int = 4

signal z_changed(new_z: float)

signal floor_changed(new_floor: int)

@onready var ground_z_detector: Node = $GroundZDetector

@onready var shadow: Node2D = $Shadow

@export var gravity_acceleration: float = 0.2

@export var z: float = 0.0:
	set = set_z

var z_speed: float = 0.0

var floor_number: int = MIN_FLOOR:
	set = set_floor_number

func set_z(new_z: float) -> void:
	if new_z < get_ground_z():
		new_z = get_ground_z()
	
	var old_z: float = z
	
	z = new_z
	
	floor_number = floori(z / TILE_SIZE) + 1
	
	set_shadow_distance(z - get_ground_z())
	
	if old_z != new_z:
		z_changed.emit(new_z)

func set_floor_number(new_floor: int) -> void:
	var old_floor: int = floor_number
	
	new_floor = clampi(new_floor, MIN_FLOOR, MAX_FLOOR)
	
	floor_number = new_floor
	
	reset_floors_collision_mask()
	
	set_collision_mask_value(floor_number, true)
	
	if old_floor != new_floor:
		floor_changed.emit(new_floor)

func get_ground_z() -> int:
	if ground_z_detector == null:
		return 0
	
	return ground_z_detector.ground_z

func set_shadow_distance(new_distance: float) -> void:
	if shadow == null:
		return
	
	shadow.distance = new_distance

func reset_floors_collision_mask() -> void:
	for i: int in range(MIN_FLOOR, MAX_FLOOR + 1):
		set_collision_mask_value(i, false)

func is_on_ground() -> bool:
	return z <= get_ground_z()

func is_on_air() -> bool:
	return not is_on_ground()

func _ready() -> void:
	z_changed.emit(z)
	floor_changed.emit(floor_number)

func _physics_process(delta: float) -> void:
	if is_on_air():
		z_speed -= gravity_acceleration
	
	if is_on_ground():
		if z_speed < 0.0:
			z_speed = 0.0
		
		z = get_ground_z()
	
	z += z_speed

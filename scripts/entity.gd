## The [Entity] node is a specialized type of
## [CharacterBody2D] that offers an additional
## z axis to manipulate.
class_name Entity
extends CharacterBody2D

## The [const TILE_SIZE] constant stores what
## is the size of the tiles in the game. This is
## used for calculations regarding what collision floor
## ([member floor_number]) this entity is in.
const TILE_SIZE: int = 16

## The [const MIN_FLOOR] constant stores what
## is the minimum value that the [member floor_number]
## can have.
const MIN_FLOOR: int = 1

## The [const MAX_FLOOR] constant stores what
## is the maximum value that the [member floor_number]
## can have.
const MAX_FLOOR: int = 4

## The [signal z_changed] signal is emitted to signalize
## when the [member z] axis of this [Entity] is changed.
signal z_changed(new_z: float)

## The [signal floor_changed] signal is emitted to signalize
## when the [member floor_number] of this [Entity] is changed.
signal floor_changed(new_floor: int)

## The [member ground_z_detector] property stores a
## reference to a node that helps detecting what is the
## z level of the ground under this [Entity],
## based on tile data.
@onready var ground_z_detector: Node = $GroundZDetector

## The [member shadow] property stores a reference to
## the shadow of this [Entity], so that this [Entity]
## can update its state when needed.
@onready var shadow: Node2D = $Shadow

## The [member gravity_acceleration] property dictates
## how fast this [Entity] will be pulled by gravity
## when it is on air.
@export var gravity_acceleration: float = 0.2

## The [member z] property refers to the location in
## the z axis where this [Entity] is in the moment.
## This information is useful for creating a fake 3D
## effect, possibilitating interactions between [Entity]s
## and tiles in this axis as well. [br]
## Changing the value of this property will emit a
## [signal z_changed] signal and also trigger the update
## of the [member floor_number] property. [br]
## Note that the setter of this property will prevent that
## a value smaller than the current ground z is set so that
## this [Entity] doesn't get inside the ground. [br]
## Finally, updates to this property will trigger the update
## of the current state of this [Entity]'s [member shadow],
## so it gives the correct visual feedback.
@export var z: float = 0.0:
	set = set_z

## The [member z_speed] property stores what is the
## current speed of this [Entity] in the z axis, so that
## calculations can be made in the physics process and
## this speed can be applied to the actual z position.
var z_speed: float = 0.0

## The [member floor_number] property stores the current
## floor where this [Entity] is. [br]
## A floor in this context refers to what collision mask
## this [Entity] has in the moment, which means it
## will only collide with stuff that is on the same floor.
## [br]
## Changing this property causes the emission of the
## [signal floor_changed] signal. [br]
## The setter of this property will prevent that it is set
## to a value outside the
## [[const MIN_FLOOR] and [const MAX_FLOOR]] interval.
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

func is_on_ground() -> bool:
	return z <= get_ground_z()

func is_on_air() -> bool:
	return not is_on_ground()

# This method is emitting the z_changed and floor_changed signals
# so that nodes that are only ready now can update according
# to these new values that might have been set in the editor.
func _ready() -> void:
	z_changed.emit(z)
	floor_changed.emit(floor_number)

# This method is responsible for calculating the z related
# physics.
func _physics_process(delta: float) -> void:
	if is_on_air():
		z_speed -= gravity_acceleration
	
	if is_on_ground():
		if z_speed < 0.0:
			z_speed = 0.0
		
		z = get_ground_z()
	
	z += z_speed

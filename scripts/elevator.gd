## The [Elevator] node is responsible for updating
## [CollisionObject2D]s that are its children, or that are
## set in the [member extra_passengers] property so that
## their [member CollisionObject2D.collision_layer] and
## [member CollisionObject2D.collision_mask] stay congruent
## with the [member floor_level] set here. [br]
## This class uses [Elevator] terms as an analogy so that
## it can be easily understood. Some of those terms are
## floor and passengers. Following is an explanation of them: [br]
## The floor in this context is an [code]integer[/code] that can
## be any number in a certain interval between [code]1[/code]
## and [code]32[/code]. This number determines in what layer the
## collision of this [Elevator]'s passengers should be active. [br]
## The passengers of this elevator is just a simplified way of
## referring to all the [CollisionObject2D] nodes that it controls.
class_name Elevator
extends Node2D

## The [const MIN_FLOOR] constant determines what is the minimum
## level that the [member floor_level] should reach.
const MIN_FLOOR: int = 1

## The [const MAX_FLOOR] constant determines what is the maximum
## level that the [member floor_level] should reach.
const MAX_FLOOR: int = 32

## The [signal floor_level_changed] signal is emitted to notify
## when the [member floor_level] property is changed.
signal floor_level_changed(new_level: int)

## The [member initial_floor] property indicates what is the minimum
## floor to where this [Elevator] can go.
@export var initial_floor: int = MIN_FLOOR

## The [member floors_amount] property determines how many
## floors can be used by this [Elevator]. [br]
## By default, this property is set to the
## [const MAX_FLOOR].
@export var floors_amount: int = MAX_FLOOR

## The [member floor_level] property stores what is the current
## floor in which this [Elevator] is. [br]
## On set, this property updates all the passengers of this [Elevator]
## so that their [member CollisionObject2D.collision_layer] and
## [member CollisionObject2D.collision_mask] match the expected for
## [CollisionObject2D]s in the new floor. [br]
## When changed, this property's setter will emit
## the [signal floor_level_changed] signal to notify the event. [br]
## Finally, the default value of this property is set to match
## the value of the [member initial_floor] property.
@export var floor_level: int = initial_floor:
	set = set_floor_level

## The [member update_passengers_layer] property stores a [code]bool[/code]
## that indicates if this [Elevator] should control its passenger's
## [member CollisionObject2D.collision_layer] on floor change.
@export var update_passengers_layer: bool = true

## The [member update_passengers_mask] property stores a [code]bool[/code]
## that indicates if this [Elevator] should control its passenger's
## [member CollisionObject2D.collision_mask] on floor change.
@export var update_passengers_mask: bool = true

## The [member extra_passengers] property stores an [Array] of
## [CollisionObject2D] representing the passengers that this
## [Elevator] should manipulate that are not in its children list. [br]
## This property is provided so that the [CollisionObject2D]s that
## should be controlled by this [Elevator] don't necessarily need to
## be its children in the node hierarchy.
@export var extra_passengers: Array[CollisionObject2D] = []

func set_floor_level(new_level: int) -> void:
	var old_level: int = floor_level
	
	floor_level = new_level
	
	update_passengers()
	
	if old_level != new_level:
		floor_level_changed.emit(new_level)

## The [method update_passenger_collision] method takes one
## [CollisionObject2D] as a [param passenger],
## a [param layer], which is an [code]integer[/code], and a
## [code]bool[/code] in the [param new_value] parameter. [br]
## This method then updates the [param passenger]'s collision
## layer identified by the [param layer] parameter, altering its
## [member CollisionObject2D.collision_layer]
## (if [member update_passengers_layer] is
## [code]true[/code]) and its [member CollisionObject2D.collision_mask]
## (if [member update_passengers_mask] is [code]true[/code]) so
## that they match the [param new_value]. [br]
## If the [param layer] passed is out of the
## [[member initial_floor], [member initial_floor] + [member floors_amount]]
## interval, this method won't do anything. [br]
## Finally, in the case the [param passenger] is an [Area2D],
## its [member Area2D.monitoring] option is turned on and off
## to workaround a bug described in this issue of
## the Godot repository:
## [url]https://github.com/godotengine/godot/issues/53997[/url]
func update_passenger_collision(
	passenger: CollisionObject2D,
	layer: int,
	new_value: bool
) -> void:
	if (
		layer < initial_floor or
		layer >= initial_floor + floors_amount
	):
		return
		
	if update_passengers_layer:
		passenger.set_collision_layer_value(layer, new_value)
	if update_passengers_mask:
		passenger.set_collision_mask_value(layer, new_value)
	
	if passenger is Area2D:
		if passenger.monitoring:
			passenger.monitoring = false
			passenger.monitoring = true

## The [method reset_passenger_collision] method
## iterates through every floor of a passenger's collision
## layers and masks, setting them to [code]false[/code] if
## the [member update_passengers_layer] and
## [member update_passengers_mask] properties are set to
## [code]true[/code], respectively.
func reset_passenger_collision(passenger: CollisionObject2D) -> void:
	for i: int in range(MIN_FLOOR, floors_amount + 1):
		update_passenger_collision(passenger, i, false)

## The [method update_child_passengers] method iterates over
## the children of this [Elevator] and updates their
## collision layer (if [member update_passengers_layer] is
## [code]true[/code]) and collision mask (if
## [member update_passengers_mask] is
## [code]true[/code]) according to the current
## [member floor_level] value.
func update_child_passengers() -> void:
	for child: Node in get_children():
		if child is not CollisionObject2D:
			continue
		
		var passenger := child as CollisionObject2D
		
		reset_passenger_collision(passenger)
		update_passenger_collision(passenger, floor_level, true)

## The [method update_extra_passengers] method iterates over
## the [CollisionObject2D]s set in the [member extra_passengers]
## of this [Elevator], making their
## collision layer (if [member update_passengers_layer] is
## [code]true[/code]) and collision mask (if
## [member update_passengers_mask] is
## [code]true[/code]) be in accordance to the current
## [member floor_level] value.
func update_extra_passengers() -> void:
	for passenger: CollisionObject2D in extra_passengers:
		reset_passenger_collision(passenger)
		update_passenger_collision(passenger, floor_level, true)

## The [method update_passengers] method iterates over
## the child passengers of this [Elevator] using the
## [method update_child_passengers] method and also
## over the [member extra_passengers], using the
## [method update_extra_passengers] method. [br]
## For more details, see those methods.
func update_passengers() -> void:
	update_child_passengers()
	update_extra_passengers()

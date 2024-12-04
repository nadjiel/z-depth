## The [Character] node is a specific type of
## [Entity] that the player can control.
class_name Character
extends Entity

## The [signal facing_direction_changed] signal is emitted
## to notify when the facing direction of this [Character]
## has changed.
signal facing_direction_changed(new_direction: Vector2)

## The [member animation_tree] property stores a
## reference to the [AnimationTree] responsible for
## animating this [Character].
@onready var animation_tree: AnimationTree = $AnimationTree

## The [member speed] property refers to at what
## speed this [Character] should move when inputed to do so.
@export var speed: float = 4.0 * 16

## The [member jump_acceleration] property stores what
## should be the acceleration applied to this [Character]
## when it is inputed to jump.
@export var jump_acceleration: float = 2.8

## The [member high_jump_acceleration] property stores what
## should be the acceleration applied to this [Character]
## when it is inputed to do a high jump.
@export var high_jump_acceleration: float = 5.0

## The [member facing_direction] property stores at what direction
## this [Character] should be facing now. [br]
## This property can only be one of
## the four directions. [br]
## On change, this property triggers the
## [signal facing_direction_changed] signal.
var facing_direction: Vector2 = Vector2.RIGHT:
	set = set_facing_direction

## The [member direction] property stores at what direction
## this [Character] should move in the moment, according to
## the input received.
var direction: Vector2 = Vector2.ZERO

func set_facing_direction(new_direction: Vector2) -> void:
	var old_direction: Vector2 = facing_direction
	
	if new_direction.is_equal_approx(Vector2.UP):
		new_direction = Vector2.UP
	elif new_direction.is_equal_approx(Vector2.RIGHT):
		new_direction = Vector2.RIGHT
	elif new_direction.is_equal_approx(Vector2.DOWN):
		new_direction = Vector2.DOWN
	elif new_direction.is_equal_approx(Vector2.LEFT):
		new_direction = Vector2.LEFT
	else:
		return
	
	facing_direction = new_direction
	
	if old_direction != new_direction:
		facing_direction_changed.emit(new_direction)

# This method is responsible for receiving the input and
# transforming it in the behavior of this Character.
# It performs the movementation of this Character in
# the x and y axis, as well as in the z axis.
# Finally, this method also updates the blend position
# of this Character's animation tree, so that its animation
# is played according to its facing direction.
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	direction = Input.get_vector(
		"left", "right", "up", "down"
	)
	
	facing_direction = direction
	
	velocity = speed * direction
	
	if is_on_ground():
		if Input.is_action_just_pressed("jump"):
			z_speed += jump_acceleration
		elif Input.is_action_just_pressed("high_jump"):
			z_speed += high_jump_acceleration
	
	move_and_slide()
	
	var state_machine: AnimationNodeStateMachinePlayback = animation_tree.get(
		"parameters/playback"
	)
	
	var current_state: StringName = state_machine.get_current_node()
	
	animation_tree.set(
		"parameters/%s/blend_position" % current_state,
		facing_direction
	)


class_name Character
extends Entity

signal facing_direction_changed(new_direction: Vector2)

@onready var animation_tree: AnimationTree = $AnimationTree

@export var speed: float = 4.0 * 16

@export var jump_acceleration: float = 2.8

@export var high_jump_acceleration: float = 5.0

var facing_direction: Vector2 = Vector2.RIGHT:
	set = set_facing_direction

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

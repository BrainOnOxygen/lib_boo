class_name CB2DBehaviorManager extends Node2D
## Manager for CB2D behaviors - central hub that manages all behaviors

signal behavior_added(behavior)
signal behavior_removed(behavior)
signal movement_changed(direction: Vector2)

@export var characterBody: CharacterBody2D
@export var shouldCallMoveAndSlide := false
@export var jumpAction: StringName = "jump"
@export var leftAction: StringName = "move_left"
@export var rightAction: StringName = "move_right"
@export var upAction: StringName = "move_up"
@export var downAction: StringName = "move_down"

var _behaviors: Array = []

func _ready():
	if not characterBody:
		characterBody = get_parent() as CharacterBody2D
	if not characterBody:
		push_error("CB2DBehaviorManager must be a child of CharacterBody2D")
		return
	
	# Collect all existing behaviors
	_CollectBehaviors()

func _process(_delta: float) -> void:
	if shouldCallMoveAndSlide:
		characterBody.move_and_slide()

func _input(_event):
	var new_vector = Input.get_vector(leftAction, rightAction, upAction, downAction)
	_UpdateMoveInput(new_vector)
	
func _CollectBehaviors():
	_behaviors.clear()
	for child in get_children():
		if child is CB2DBehavior:
			_behaviors.append(child)
			# Set the character body reference for each behavior
			child.SetCharacterBody(characterBody)
			behavior_added.emit(child)

## Public methods
func add_behavior(behavior: CB2DBehavior):
	if behavior and not _behaviors.has(behavior):
		add_child(behavior)
		_behaviors.append(behavior)
		# Set the character body reference
		behavior.SetCharacterBody(characterBody)
		behavior_added.emit(behavior)

func remove_behavior(behavior: CB2DBehavior):
	if behavior and _behaviors.has(behavior):
		_behaviors.erase(behavior)
		behavior_removed.emit(behavior)
		behavior.queue_free()

func get_behavior(behavior_type: GDScript) -> CB2DBehavior:
	for behavior in _behaviors:
		if behavior.get_script() == behavior_type:
			return behavior
	return null

func get_behaviors() -> Array[CB2DBehavior]:
	return _behaviors.duplicate()

func enable_all_behaviors(enabled: bool):
	for behavior in _behaviors:
		behavior.enabled = enabled

func enable_behavior_type(behavior_type: GDScript, enabled: bool):
	var behavior = get_behavior(behavior_type)
	if behavior:
		if behavior.has_variable("enabled"):
			behavior.enabled = enabled

## Convenience methods for specific behaviors

# --- Internal input state and dispatch ---
var _movement_direction: Vector2 = Vector2.ZERO
var _left_down: bool = false
var _right_down: bool = false
var _up_down: bool = false
var _down_down: bool = false

func _UpdateMoveInput(direction: Vector2):
	if direction != _movement_direction:
		_movement_direction = direction
		movement_changed.emit(_movement_direction)
		for behavior in _behaviors:
			behavior.OnMovementInput(direction)

func _dispatch_action_pressed(canonical_action: String):
	for behavior in _behaviors:
		behavior.OnActionPressed(canonical_action)

func _dispatch_action_released(canonical_action: String):
	for behavior in _behaviors:
		behavior.OnActionReleased(canonical_action)

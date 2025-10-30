class_name CB2DTopDownMove extends CB2DBehavior
## Smooth top-down movement behavior for CharacterBody2D
## Provides acceleration, deceleration, and friction for fluid movement

@export_group("Movement Settings")
@export var maxSpeed: float = 200.0
@export var acceleration: float = 800.0
@export var friction: float = 600.0

@export_group("Debug")
@export var ShowDebugInfo: bool = false

var _current_velocity: Vector2 = Vector2.ZERO
var _inputDirection: Vector2 = Vector2.ZERO
var _lastMoveDirection: Vector2 = Vector2.ZERO

var LastMoveDirection: Vector2:
	get: return _lastMoveDirection

func _PhysicsProcessBehavior(delta: float):
	if not _character_body:
		return
	
	_ApplyMovement(delta)
	_character_body.velocity = _current_velocity
	
	if ShowDebugInfo:
		_debug_print()

func OnMovementInput(direction: Vector2):
	_inputDirection = direction.normalized()
	if direction != Vector2.ZERO:
		_lastMoveDirection = _inputDirection

func _ApplyMovement(delta: float):
	if _inputDirection != Vector2.ZERO:
		# Accelerate towards input direction
		_current_velocity = _current_velocity.move_toward(
			_inputDirection * maxSpeed, 
			acceleration * delta
		)
	else:
		# Apply friction when no input
		_current_velocity = _current_velocity.move_toward(
			Vector2.ZERO, 
			friction * delta
		)
	if _current_velocity.length() > 0.001:
		_lastMoveDirection = _current_velocity.normalized()

func _debug_print():
	print("🎮 TopDown Move - Input: %s | Velocity: %s | Speed: %.1f" % [
		_inputDirection, 
		_current_velocity, 
		_current_velocity.length()
	])

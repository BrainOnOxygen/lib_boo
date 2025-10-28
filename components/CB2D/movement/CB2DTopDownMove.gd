class_name CB2DTopDownMove extends CB2DBehavior
## Smooth top-down movement behavior for CharacterBody2D
## Provides acceleration, deceleration, and friction for fluid movement

@export_group("Movement Settings")
@export var MaxSpeed: float = 200.0
@export var Acceleration: float = 800.0
@export var Friction: float = 600.0

@export_group("Debug")
@export var ShowDebugInfo: bool = false

var _current_velocity: Vector2 = Vector2.ZERO
var _inputDirection: Vector2 = Vector2.ZERO

func _PhysicsProcessBehavior(delta: float):
	if not _character_body:
		return
	
	_ApplyMovement(delta)
	_character_body.velocity = _current_velocity
	
	if ShowDebugInfo:
		_debug_print()

func OnMovementInput(direction: Vector2):
	_inputDirection = direction.normalized()

func _ApplyMovement(delta: float):
	if _inputDirection != Vector2.ZERO:
		# Accelerate towards input direction
		_current_velocity = _current_velocity.move_toward(
			_inputDirection * MaxSpeed, 
			Acceleration * delta
		)
	else:
		# Apply friction when no input
		_current_velocity = _current_velocity.move_toward(
			Vector2.ZERO, 
			Friction * delta
		)

func _debug_print():
	print("🎮 TopDown Move - Input: %s | Velocity: %s | Speed: %.1f" % [
		_inputDirection, 
		_current_velocity, 
		_current_velocity.length()
	])

class_name KnockbackAct extends Node2DAct

@export var actor: Node2D
@export var default_knockback_force: float = 5.0

func Execute(parameter: Variant = null) -> Variant:
	var knockback_vector: Vector2 = parameter if parameter is Vector2 else _GetDefaultKnockback()

	if actor.has_method("ApplyKnockback"):
		actor.ApplyKnockback(knockback_vector)
		return null
	elif actor is RigidBody2D:
		actor.apply_central_impulse(knockback_vector)
	elif actor is CharacterBody2D:
	# TODO: Implement for CharacterBody2D and Node2D
		pass

	return null

func _GetDefaultKnockback() -> Vector2:
	var current_velocity := Vector2.ZERO
	
	if actor is RigidBody2D:
		current_velocity = actor.linear_velocity
	# TODO: Add velocity checks for CharacterBody2D
	
	return -current_velocity.normalized() * default_knockback_force

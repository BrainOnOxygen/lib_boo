## Info on any hit, including power, knockback and status to apply.
class_name HitData extends Resource

@export var hitName:String = ""
@export var power: int = 1
@export var knockbackMultiplier: float = 1.0  # 1.0 = normal, 2.0 = double, 0.5 = half
@export var isIntervalEffect: bool = false # If true, effect persists while in hitbox
#@export var statusEffects: Dictionary = {} # Format: { "slow": 0.5, "duration": 2.0 } etc.

var hitPosition: Vector2 ##Where the hit happened, in 2D.

var KnockbackForce:float:
	get: return BASE_KNOCKBACK_FORCE * knockbackMultiplier

# Base knockback force - adjust this globally to tune all knockback
const BASE_KNOCKBACK_FORCE: float = 1000.0

func _init(p_power: int = 1, knockback_mult: float = 1.0) -> void:
	self.power = p_power
	self.knockbackMultiplier = knockback_mult


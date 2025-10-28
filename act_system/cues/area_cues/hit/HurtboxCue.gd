@icon("res://lib_boo/assets/class_icons_custom/HurtboxTrigger.svg")
class_name HurtboxCue extends Area2DCue

signal hit_received(hit_data: HitData)
signal knockback_calculated(knockback_vector: Vector2)

@export var nodeForInvulVisual: Node2D
@export var invulnerabilityDuration: float = 0.0
# @export var showDamagePopup: bool = true

var _namedHitboxes: Dictionary = {}
var isInvincible: bool = false:
	set(value):
		isInvincible = value
		if isInvincible:
			DisableColliders()
		else:
			EnableColliders()
		
		if nodeForInvulVisual:
			nodeForInvulVisual.modulate.a = 0.5 if isInvincible else 1.0


func _ready() -> void:
	super._ready()

func Execute(hit: HitData = null) -> void:
	CueActs(hit)

func CueActs(hit: HitData = null):
	if hit:
		hit_received.emit(hit)
		

		var knockback_dir = (global_position - hit.hitPosition).normalized()
		var knockback_vector = knockback_dir * hit.KnockbackForce
		knockback_calculated.emit(knockback_vector)
		
		cue.CueActs(hit)
		_SignalOutTriggerers(hit)
		if invulnerabilityDuration > 0.0:
			isInvincible = true
			await get_tree().create_timer(invulnerabilityDuration).timeout
			isInvincible = false

func _SpawnDamagePopup(hit: HitData) -> void:
	GM.ShowTextPopup(str(hit.power), GM.world, hit.hitPosition)

func CheckNamedHitbox(hitbox_name: String) -> bool:
	return _namedHitboxes.has(hitbox_name)

func AddNamedHitbox(hitbox_name: String, hitbox: HitboxCue) -> void:
	_namedHitboxes[hitbox_name] = hitbox

func RemoveNamedHitbox(hitbox_name: String) -> void:
	_namedHitboxes.erase(hitbox_name)

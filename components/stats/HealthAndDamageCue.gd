@tool
@icon("res://lib_boo/assets/class_icons_custom/health_icon.svg")
class_name HealthAndDamageCue extends CueNode

const IS_STATEFUL_CUE := true ## Marks this Cue as stateful to make it explicit

signal health_changed(new_health: int, max_health: int)
signal got_hit(hit:HitData)
signal damage_applied(input_damage: int, damage_dealt: int, hit_name: String)
signal no_health()

@export var canBeReducedToZero: bool = true
@export var canBeHitBelowZero: bool = true

@export var animateOnDamageTarget:Node2D = null: ##If this is not null, then we show hitflash
	set(value):
		animateOnDamageTarget = value
		notify_property_list_changed()

var autoConnectToChildHurtboxes: bool = true

@export var showDamagePopup: bool = true

##Dynamic property
var scaleOnDamage: float = 1.0 ##If this is any value but 1.0, we trigger a scale tween

@export var MaxHealth: int = 3:
	get:
		return MaxHealth
	set(value):
		var difference = MaxHealth - Health
		MaxHealth = value
		Health = MaxHealth - difference

var Health: int = 3:
	get:
		return Health
	set(value):
		if value <= 0 and not canBeReducedToZero:
			value = 1
		Health = value
		health_changed.emit(Health, MaxHealth)
		if shouldCueOnHealthChange:
			CueActs()
		
		if value <= 0:
			no_health.emit()
		
		if is_node_ready():
			if showHp:
				hpLabel.text = str(Health)

var HealthPercentage: float:
	get:
		return float(Health) / float(MaxHealth)

@export var shouldCueOnHealthChange: bool = false

@export var showHp := true:
	get:
		return showHp
	set(value):
		showHp = value

		if not is_node_ready():
			return
		hpLabel.visible = showHp

var IsMissingHealth:bool:
	get: return Health < MaxHealth

var isInvincible: bool = false
var _hurtboxes: Array[HurtboxCue] = []
var _flash_tween: Tween
var _is_tween_running: bool = false

@onready var hpLabel: Label = $HpLabel

func _ready() -> void:
	_SetUpHealth()
	child_entered_tree.connect(_OnChildEnteredTree)
	if autoConnectToChildHurtboxes:
		_ConnectToChildHurtboxes()
	
	if showHp:
		hpLabel.visible = true
		hpLabel.text = str(Health)

func _PlayOnDamageEffect() -> void:
	if not animateOnDamageTarget or _is_tween_running:
		return
	
	const SINGLE_FRAME_DURATION: float = 0.01667 #Actual single frame duration
	# const SINGLE_FRAME_DURATION: float = 0.05
		
	if _flash_tween:
		_flash_tween.kill()
	
	_is_tween_running = true
	
	# Set the Health percentage in the shader
	animateOnDamageTarget.material.set_shader_parameter("health_percentage", HealthPercentage)
	
	_flash_tween = create_tween()
	_flash_tween.tween_property(animateOnDamageTarget, "material:shader_parameter/flash_value", 1.0, SINGLE_FRAME_DURATION)
	_flash_tween.tween_property(animateOnDamageTarget, "material:shader_parameter/flash_value", 0.0, SINGLE_FRAME_DURATION)
	
	if scaleOnDamage != 1.0:
		var scale_tween = create_tween()
		scale_tween.tween_property(animateOnDamageTarget, "scale", Vector2(scaleOnDamage, scaleOnDamage), SINGLE_FRAME_DURATION)
		scale_tween.tween_property(animateOnDamageTarget, "scale", Vector2(1.0, 1.0), SINGLE_FRAME_DURATION)
	
	# Wait for all tweens to complete before allowing new ones
	await get_tree().create_timer(SINGLE_FRAME_DURATION * 2).timeout
	_is_tween_running = false

func CalculateDamage(damage: int, hit: HitData = null) -> void:
	if isInvincible: 
		return
	
	var initial_health := Health
	Health = max(0, Health - damage)
	var damage_dealt := initial_health - Health
	
	_SpawnDamagePopup(damage_dealt)
	if hit:	
		got_hit.emit(hit)
	damage_applied.emit(damage, damage_dealt, hit.hitName if hit else "")
	_PlayOnDamageEffect()

	

func _OnHitReceived(hit: HitData) -> void:
	if not canBeHitBelowZero and HealthPercentage <= 0:
		return
	CalculateDamage(hit.power, hit)

func _SetUpHealth() -> void:
	Health = MaxHealth
	if showHp:
		hpLabel.text = str(Health)
	else:
		hpLabel.visible = false
	
	await get_tree().create_timer(0.1).timeout
	health_changed.emit(Health, MaxHealth)

func _ConnectToChildHurtboxes() -> void:
	for child in get_children():
		if child is HurtboxCue:
			_AddHurtbox(child)

func _OnChildEnteredTree(child: Node) -> void:
	if not autoConnectToChildHurtboxes: return

	if child is HurtboxCue:
		_AddHurtbox(child)

func _AddHurtbox(hurtbox: HurtboxCue) -> void:
	_hurtboxes.append(hurtbox)
	
	if not hurtbox.hit_received.is_connected(_OnHitReceived):
		hurtbox.hit_received.connect(_OnHitReceived)

func _RemoveHurtbox(hurtbox: HurtboxCue) -> void:
	_hurtboxes.erase(hurtbox)

func Heal(amount: int) -> void:
	Health = min(Health + amount, MaxHealth)
	health_changed.emit(Health, MaxHealth)

func DepleteHealth() -> void:
	canBeReducedToZero = true
	Health = 0

func _get_property_list() -> Array:
	var properties: Array[Dictionary] = []
	
	# Only show scaleOnDamage when animateOnDamageTarget is set
	if animateOnDamageTarget != null:
		properties.append({
			"name": "scaleOnDamage",
			"type": TYPE_FLOAT,
			"usage": PROPERTY_USAGE_DEFAULT
		})
	
	return properties


func _SpawnDamagePopup(damage: int) -> void:
	GM.ShowTextPopup(str(damage), GM.world, global_position)

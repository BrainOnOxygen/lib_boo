@icon("res://lib_boo/assets/class_icons_custom/HitboxTrigger.svg")
class_name HitboxCue extends Area2DCue

signal hit_landed(hurtbox: HurtboxCue, hit: HitData)

@export var hitData: HitData
@export var hitboxName: String ## Use to check against this named Hitbox
@export var canStack := true ## For repeated hit hurtboxes. If FALSE, Hurtbox only takes damage from a single one when boxes overlap.
@export var canRepeatHit: bool = false
@export var maxHits: int = 9999 ## Maximum number of hurtboxes this hitbox can hit (0 = unlimited)

@export var hitOnEnter: bool = true
@export var ignoredHurtboxes: Array[HurtboxCue] = []

var _currentHits: int = 0 ## Tracks how many successful hits have been made
var _collidedHurtboxes: Array[HurtboxCue] = []

func _ready() -> void:
	super()
	area_entered.connect(_on_hurtbox_entered)
	area_exited.connect(_on_hurtbox_exited)

func _on_hurtbox_entered(area: Area2D) -> void:
	if not hitOnEnter: return
	TryHit(area)


func TryHit(area:Area2D) -> bool:
	var hurtbox = area as HurtboxCue
	if not hurtbox or hurtbox.isInvincible: return false
	if _collidedHurtboxes.has(hurtbox) and not canRepeatHit: return false
	if maxHits > 0 and _currentHits >= maxHits: return false
	
	_collidedHurtboxes.append(hurtbox)
	
	if not canStack and hurtbox.CheckNamedHitbox(hitboxName): return false
	
	if not canStack:
		hurtbox.AddNamedHitbox(hitboxName, self)
	
	_handle_hit(hurtbox)
	return true

func _handle_hit(hurtbox: HurtboxCue) -> void:
	var hit = _create_new_hit(hurtbox)
	hit.set_meta("source", self) # Add hitbox as source for status tracking
	_currentHits += 1
	hit_landed.emit(hurtbox, hit)
	hurtbox.CueActs.call_deferred(hit)
	cue.CueActs.call_deferred()
	
	if maxHits > 0 and _currentHits >= maxHits:
		DisableColliders.call_deferred()

func _create_new_hit(hurtbox: HurtboxCue) -> HitData:
	var new_hit = hitData.duplicate(true)
	
	# Calculate the actual hit position
	var hit_position = _calculate_hit_position(hurtbox)
	new_hit.hitPosition = hit_position
	return new_hit

func _calculate_hit_position(hurtbox: HurtboxCue) -> Vector2:
	# Get the shapes involved in the collision
	var hitbox_shapes = []
	var hurtbox_shapes = []
	
	for child in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			hitbox_shapes.append(child)
	
	for child in hurtbox.get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			hurtbox_shapes.append(child)
	
	# Find the closest points between the shapes
	var closest_distance = INF
	var best_position = global_position
	
	for hitbox_shape in hitbox_shapes:
		for hurtbox_shape in hurtbox_shapes:
			var hit_pos = _find_closest_point(hitbox_shape, hurtbox_shape)
			var distance = global_position.distance_to(hit_pos)
			
			if distance < closest_distance:
				closest_distance = distance
				best_position = hit_pos
	
	return best_position

func _find_closest_point(shape1: Node2D, shape2: Node2D) -> Vector2:
	# Get the centers of both shapes in global coordinates
	var center1 = shape1.global_position
	var center2 = shape2.global_position
	
	# If either shape is a CollisionShape2D, adjust the center based on shape type
	if shape1 is CollisionShape2D:
		center1 = _adjust_shape_center(shape1 as CollisionShape2D)
	if shape2 is CollisionShape2D:
		center2 = _adjust_shape_center(shape2 as CollisionShape2D)
	
	# Return the midpoint between the shapes
	return (center1 + center2) / 2

func _adjust_shape_center(shape: CollisionShape2D) -> Vector2:
	if not shape.shape: return shape.global_position
	
	var pos = shape.global_position
	
	match shape.shape.get_class():
		"RectangleShape2D":
			# For rectangles, use the global position as is
			return pos
		"CircleShape2D":
			# For circles, use the global position as is
			return pos
		"CapsuleShape2D":
			# For capsules, use the global position as is
			return pos
		_:
			# For other shapes, default to global position
			return pos

func _on_hurtbox_exited(area: Area2D) -> void:
	var hurtbox = area as HurtboxCue
	if not hurtbox: return
	
	if hurtbox in _collidedHurtboxes:
		if not canStack:
			hurtbox.RemoveNamedHitbox(hitboxName)
		_collidedHurtboxes.erase(hurtbox)

func ResetHits() -> void:
	_currentHits = 0
	_collidedHurtboxes.clear()

func _IsOverlaps(hurtbox) -> bool:
	return get_overlapping_areas().has(hurtbox) or get_overlapping_bodies().has(hurtbox) 


func HitOverlapping():
	for area in get_overlapping_areas():
		if area is HurtboxCue:
			if ignoredHurtboxes.has(area):
				continue
			TryHit(area)

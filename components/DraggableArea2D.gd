class_name DraggableArea2D extends RefCounted

var area:Area2D = null
var isDragging := false
var dragOffset := Vector2.ZERO

func _init(actor: Area2D) -> void:
	area = actor
	area.input_event.connect(_on_input_event)


# ------------------------------------------
# 🐭 DRAG & DROP
# ------------------------------------------
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not (event is InputEventMouseButton): return
	if event.button_index != MOUSE_BUTTON_LEFT: return

	if event.pressed:
		if not area.IsFriendly():
			await GM.commandStack.PushAndRun(DealDamageCommand.new(self, 1), "clickDamage")
			return
		_StartDrag()
	else:
		if isDragging:
			_EndDrag()

func _input(event: InputEvent) -> void:
	if isDragging and event is InputEventMouseMotion:
		_UpdateDrag()

func _StartDrag() -> void:
	isDragging = true
	dragOffset = area.global_position - area.get_global_mouse_position()
	area.z_index = 10
	_SetDragVisual(true)

func _EndDrag() -> void:
	isDragging = false
	area.z_index = 0

	var target_space = GetClosestValidFieldSpace()
	if target_space:
		area.MoveToFieldSpace(target_space)
	else:
		area.TweenToPosition(area.mySpace.global_position)

func _UpdateDrag() -> void:
	area.global_position = area.get_global_mouse_position() + dragOffset

func _SetDragVisual(active: bool) -> void:
	if active:
		area.modulate = Color(1, 1, 1, 0.8)
		area.scale = Vector2(1.1, 1.1)
	else:
		area.modulate = Color.WHITE
		area.scale = Vector2.ONE



# ------------------------------------------
# 🎯 FIELD SPACE VALIDATION
# ------------------------------------------
func GetClosestValidFieldSpace() -> FieldSpace:
	var valid_spaces: Array[FieldSpace] = []

	for a in area.get_overlapping_areas():
		if a is FieldSpace:
			valid_spaces.append(a)

	if valid_spaces.is_empty():
		return null

	var closest_space: FieldSpace = null
	var closest_dist := INF

	for space in valid_spaces:
		if IsValidDropTarget(space):
			var dist = area.global_position.distance_to(space.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest_space = space

	return closest_space

func IsValidDropTarget(space: FieldSpace) -> bool:
	if not space or space == area.mySpace:
		return false

	if space.HasOccupant() and space.GetOccupant() != area:
		return false

	if space.index < 2:
		return false

	if space.index == 3:
		var lane := space.get_parent() as FieldLane
		if lane and lane.spaces.size() > 2:
			var front_space := lane.spaces[2] as FieldSpace
			var front_occupied:bool = front_space and front_space.HasOccupant() and front_space.GetOccupant() != self
			if not front_occupied:
				return false
	return true

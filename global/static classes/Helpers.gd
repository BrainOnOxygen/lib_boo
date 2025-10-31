class_name Helpers extends RefCounted

static func RandomBool() -> bool:
	return randi() % 2 == 0

static func GetRandomColor() -> Color:
	return Color(randf(), randf(), randf())

static func GetRandomValues(array:Array, count:int, can_repeat:bool = false) -> Array:
	var result:Array = []
	var available_values:Array = array.duplicate()
	
	# Ensure we don't try to get more values than available
	count = mini(count, array.size())
	
	for i in range(count):
		if available_values.is_empty():
			break
			
		var random_index:int = randi() % available_values.size()
		result.append(available_values[random_index])
		
		if not can_repeat:
			available_values.remove_at(random_index)
	
	return result

static func FindClosestNode2D(nodes: Array, position: Vector2) -> Node2D:
	var closestNode: Node2D = null
	var closestDistance: float = INF
	for node in nodes:
		if not node is Node2D:
			continue
		var node2d: Node2D = node as Node2D
		var distance = position.distance_to(node2d.global_position)
		if distance < closestDistance:
			closestDistance = distance
			closestNode = node2d
	return closestNode

static func TryKillTween(tween: Tween) -> void:
	if tween and tween.is_running():
		tween.kill()

static func FloatToTime(time: float) -> String:
	var minutes: int = floori(time / 60.0)
	var seconds: int = floori(fmod(time, 60.0))
	return "%02d:%02d" % [minutes, seconds]
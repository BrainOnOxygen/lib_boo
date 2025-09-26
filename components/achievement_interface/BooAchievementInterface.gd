## Use it to interface with AchievementManager instead of
## calling its API from all over the place.
## Extend to create your own interfaces.
class_name BooAchievementInterface extends CanvasLayer

func _ready() -> void:
	if GM.events == null:
		await GM.ready
	_ConnectGlobalEvents()

func _ConnectGlobalEvents():
	return
	#GM.events.game_start.connect(func():
		#AchievementManager.unlock_achievement("game_start"))

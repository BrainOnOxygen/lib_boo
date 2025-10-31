class_name BooGameManager extends Node

signal gm_ready

var main:BooMain
var world:BooWorld2D

@onready var textSpawner:SpawnerAct = $TextPopupSpawner
@onready var time:TimeManager = $TimeManager
@onready var globalSpawner:GlobalSpawner = $GlobalSpawner
@onready var audio:GlobalAudioPlayer = $GlobalAudioPlayer
@onready var saveLoad: BooSaveLoad = $BooSaveLoad

@onready var achieve: CanvasLayer = $GlobalEvents/AchievementInterface

@onready var events:GameEventsBus = $GlobalEvents
@onready var config: GameConfig = $GameConfig

func _ready() -> void:
	gm_ready.emit()

func ShowTextPopup(text:String, parent:Node2D = world, start_pos:Vector2 = Vector2.ZERO, color:Color = Color.WHITE) -> TextPopup:
	var popup = textSpawner.Execute({"parent":parent})[0] as TextPopup
	popup.Play(text, start_pos, color)
	return popup

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reset"):
		ResetCurrentScene()

func ResetCurrentScene() -> void:
	get_tree().reload_current_scene()

func PauseState(new_state:bool) -> void:
	get_tree().paused = new_state

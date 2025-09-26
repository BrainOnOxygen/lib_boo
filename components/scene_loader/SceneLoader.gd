extends Node

@export var mainScn:PackedScene = null
@onready var splash_screen: SplashScreen = $Splash_Screen

func _ready():
	if GM.config.ShouldSkipIntros and OS.is_debug_build():
		LoadMainScene()

func LoadMainScene():
	SceneManager.change_scene(mainScn)

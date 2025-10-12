class_name BooConfig extends Node


#region General
@export var ShouldSkipIntros: bool = false
#endregion


#region Audio Settings
@export_group("Audio Settings")
@export var IsMuted: bool = false
@export var MasterVolume: float = 0.5
@export var SFXVolume: float = 0.5
@export var MusicVolume: float = 0.5
#endregion

@export_group("Development")
@export var overrideInEditor:bool = false


# 🎯 Setter functions for configuration values
func SetShouldSkipIntros(skip: bool) -> void:
	ShouldSkipIntros = skip
	if GM:
		GM.saveLoad.SaveConfig("game_config", "general", "should_skip_intros", skip)

func SetIsMuted(muted: bool) -> void:
	IsMuted = muted
	if is_node_ready():
		GM.saveLoad.SaveConfig.call_deferred("game_config", "audio", "is_muted", muted)
	_ApplyMasterVolume()

func SetMasterVolume(vol: float) -> void:
	MasterVolume = vol
	if is_node_ready():
		GM.saveLoad.SaveConfig("game_config", "audio", "master_volume", vol)
	_ApplyMasterVolume()

func SetSFXVolume(vol: float) -> void:
	SFXVolume = vol
	# 🎯 Check if SFX bus exists before setting volume
	var sfx_bus_index = AudioServer.get_bus_index("SFX")
	if sfx_bus_index != -1:
		AudioServer.set_bus_volume_linear(sfx_bus_index, vol)

func SetMusicVolume(vol: float) -> void:
	MusicVolume = vol
	# 🎯 Check if Music bus exists before setting volume
	var music_bus_index = AudioServer.get_bus_index("Music")
	if music_bus_index != -1:
		AudioServer.set_bus_volume_linear(music_bus_index, vol)


func _ready() -> void:
	
	if overrideInEditor and OS.is_debug_build():
		return
	
	_LoadAudioVolumesFromConfig.call_deferred()

	await get_tree().process_frame
	SetShouldSkipIntros(true)

func _LoadAudioVolumesFromConfig() -> void:
	# Load all audio settings from config file on startup
	if GM.saveLoad:
		# Load values without triggering setters to avoid premature volume application
		var loaded_muted = GM.saveLoad.LoadConfig("game_config", "audio", "is_muted", false)
		var loaded_master = GM.saveLoad.LoadConfig("game_config", "audio", "master_volume", 0.5)
		var loaded_music = GM.saveLoad.LoadConfig("game_config", "audio", "music_volume", 0.5)
		var loaded_sfx = GM.saveLoad.LoadConfig("game_config", "audio", "sfx_volume", 0.5)
		
		# print("Loaded audio settings from config file:")
		# print("  Muted: ", loaded_muted)
		# print("  Master Volume: ", loaded_master)
		# print("  Music Volume: ", loaded_music)
		# print("  SFX Volume: ", loaded_sfx)
		
		# 🎯 Set values using setter functions to ensure proper saving and volume application
		SetIsMuted(loaded_muted)
		SetMasterVolume(loaded_master)
		SetMusicVolume(loaded_music)
		SetSFXVolume(loaded_sfx)
	else:
		print("Warning: GM or GM.saveLoad not available when trying to load audio volumes")

func SaveConfig() -> void:
	if GM.saveLoad:
		GM.saveLoad.SaveConfig("game_config", "audio", "is_muted", IsMuted)
		GM.saveLoad.SaveConfig("game_config", "audio", "master_volume", MasterVolume)
		GM.saveLoad.SaveConfig("game_config", "audio", "music_volume", MusicVolume)
		GM.saveLoad.SaveConfig("game_config", "audio", "sfx_volume", SFXVolume)
	else:
		print("Warning: GM or GM.saveLoad not available when trying to save audio volumes")

func _ApplyMasterVolume() -> void:
	var volume = 0.0 if IsMuted else MasterVolume
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), volume)

class_name SplashScreen extends Node2D

signal finished

func _on_timer_timeout() -> void:
	finished.emit()

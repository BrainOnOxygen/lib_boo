@tool
extends PanelContainer
signal btn_pressed(was_confirmed: bool)

@export_placeholder("Confirm") var confirmText:String = "":
	set(val):
		confirmText = val 
		_UpdateBtnText(confirm_btn, val, "Confirm")

@export_group("isBinary")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "feature") 
var isBinary:bool = true:
	get: return isBinary
	set(value):
		isBinary = value
		_UpdateDenyButtonVisibility()

@export_placeholder("Deny") var denyText:String = "":
	set(val):
		denyText = val
		_UpdateBtnText(deny_btn, val, "Deny")


@onready var confirm_btn: ButtonCue = %ConfirmBtn
@onready var deny_btn: ButtonCue = %DenyBtn

func _ready() -> void:
	confirm_btn.grab_focus()
	
	_UpdateBtnText(confirm_btn, confirmText, "Confirm")
	_UpdateBtnText(deny_btn, denyText, "Deny")
	_UpdateDenyButtonVisibility()
	

#region Signal
func _on_confirm_btn_cued() -> void:
	btn_pressed.emit(true)


func _on_cancel_btn_cued() -> void:
	btn_pressed.emit(false)

#endregion

#region Helpers
func _UpdateBtnText(button: ButtonCue, text: String, default_text: String) -> void:
	if is_node_ready():
		button.text = text if text != "" else default_text


func _UpdateDenyButtonVisibility() -> void:
	if is_node_ready():
		deny_btn.visible = isBinary
#endregion

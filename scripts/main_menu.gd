extends Control

@onready var settings_popup: Panel = $SettingsPopup

func _ready() -> void:
	$PlayButton.pressed.connect(_on_play_pressed)
	$SettingsButton.pressed.connect(_on_settings_pressed)
	
	$SettingsPopup/CloseButton.pressed.connect(_on_settings_close_pressed)
	
	settings_popup.visible = false
	
func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	
func _on_settings_pressed() -> void:
	settings_popup.visible = true
	
func _on_settings_close_pressed() -> void:
	settings_popup.visible = false

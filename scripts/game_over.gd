extends Control

@onready var texture_rect: TextureRect = $TextureRect
@onready var blur_overlay: ColorRect = $BlurOverlay

func _ready() -> void:
	hide()

func show_game_over(reason: String) -> void:
	var lower_reason = reason.to_lower()
	
	if "win" in lower_reason:
		texture_rect.texture = preload("res://assets/sprites/game_over_win.png")
	else:
		texture_rect.texture = preload("res://assets/sprites/game_over_lose.png")
	
	blur_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	show()

func _gui_input(event: InputEvent) -> void:
	if visible and event is InputEventMouseButton and event.pressed:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

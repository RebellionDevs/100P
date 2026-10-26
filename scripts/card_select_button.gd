class_name CardSelectButton
extends AnimatedTextureButton

@export var inactive_texture: Texture2D
@export var player_id: int = 1

func _ready() -> void:
	pressed.connect(_on_pressed)

func _process(delta: float) -> void:
	var target_state = GameManager.State.WAITING_FOR_CARD_P1 if GameManager.active_player == 1 else GameManager.State.WAITING_FOR_CARD_P2
	var is_active = (GameManager.current_state == target_state)
	
	disabled = not is_active
	
	if not is_active:
		if inactive_texture:
			texture_normal = inactive_texture
		return
		
	super._process(delta)

func _on_pressed() -> void:
	var target_state = GameManager.State.WAITING_FOR_CARD_P1 if GameManager.active_player == 1 else GameManager.State.WAITING_FOR_CARD_P2
	if GameManager.current_state != target_state:
		return
		
	var ui = get_tree().current_scene.find_child("CardSelectionUI", true, false)
	if ui and ui.has_method("open_cards"):
		ui.open_cards()

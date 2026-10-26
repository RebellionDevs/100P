class_name CardSelectButton
extends AnimatedTextureButton

@export var inactive_texture: Texture2D
@export var player_id: int = 1

func _ready() -> void:
	pressed.connect(_on_pressed)

func _process(delta: float) -> void:
	var has_active_bullet = GameManager.active_bullet != null and is_instance_valid(GameManager.active_bullet)
	var is_active = (
		(GameManager.current_state == GameManager.State.PLAYER_1_TURN or
		GameManager.current_state == GameManager.State.PLAYER_2_TURN) and
		has_active_bullet
	)
	
	disabled = not is_active
	
	if not is_active:
		if inactive_texture:
			texture_normal = inactive_texture
		return
		
	super._process(delta)

func _on_pressed() -> void:
	if GameManager.current_state != GameManager.State.PLAYER_1_TURN and \
			GameManager.current_state != GameManager.State.PLAYER_2_TURN:
		return
	if GameManager.active_bullet == null or not is_instance_valid(GameManager.active_bullet):
		return
		
	var ui = get_tree().current_scene.find_child("CardSelectionUI", true, false)
	if ui and ui.has_method("open_cards"):
		ui.open_cards()

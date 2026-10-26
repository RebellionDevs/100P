class_name CardSelectButton
extends AnimatedTextureButton

@export var inactive_texture: Texture2D

func _process(delta: float) -> void:
	var is_active = (GameManager.current_state == GameManager.State.WAITING_FOR_CARD)
	
	disabled = not is_active
	
	if not is_active:
		if inactive_texture:
			texture_normal = inactive_texture
		return
		
	super._process(delta)

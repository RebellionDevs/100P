extends TextureRect

@export var logo_frames: Array[Texture2D] = []
@export var change_interval: float = 0.15

var timer: float = 0.0

func _process(delta: float) -> void:
	if logo_frames.is_empty():
		return
		
	timer += delta
	if timer >= change_interval:
		timer = 0.0
		texture = logo_frames[randi() % logo_frames.size()]

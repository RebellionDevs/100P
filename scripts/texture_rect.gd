extends TextureRect

@export var frames: Array[Texture2D] = []
@export var frame_interval: float = 0.4

var current_frame: int = 0
var timer: float = 0.0

func _ready() -> void:
	update_frame()

func _process(delta: float) -> void:
	if frames.size() < 2:
		return
		
	timer += delta
	if timer >= frame_interval:
		timer = 0.0
		current_frame = 1 if current_frame == 0 else 0
		update_frame()

func update_frame() -> void:
	if frames.size() >= 2:
		texture = frames[current_frame]
	elif not frames.is_empty():
		texture = frames[0]

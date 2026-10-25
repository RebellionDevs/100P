class_name AnimatedTextureButton
extends TextureButton

@export var normal_frames: Array[Texture2D] = []
@export var hover_frames: Array[Texture2D] = []

@export var frame_interval: float = 0.4

var current_frame: int = 0
var timer: float = 0.0
var is_hovered_state: bool = false

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	update_texture()
	
func _process(delta: float) -> void:
	timer += delta
	if timer >= frame_interval:
		timer = 0.0
		current_frame = 1 if current_frame == 0 else 0
		update_texture()
		
func _on_mouse_entered() -> void:
	is_hovered_state = true
	current_frame = 0
	timer = 0.0
	update_texture()

func _on_mouse_exited() -> void:
	is_hovered_state = false
	current_frame = 0
	timer = 0.0
	update_texture()
	
func update_texture() -> void:
	if is_hovered_state and hover_frames.size() >= 2:
		texture_normal = hover_frames[current_frame]
	elif not is_hovered_state and normal_frames.size() >= 2:
		texture_normal = normal_frames[current_frame]
	elif normal_frames.size() > 0:
		texture_normal = normal_frames[0]

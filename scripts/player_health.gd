extends Control

@export var heart_full_frames: Array[Texture2D] = []
@export var heart_empty_frames: Array[Texture2D] = []

@export var max_hp: int = 3
@export var current_hp: int = 3

@export var heart_size: Vector2 = Vector2(32, 32)
@export var spacing: float = 6.0
@export var anim_interval: float = 0.4

var timer: float = 0.0
var current_frame: int = 0

func _ready() -> void:
	update_health(current_hp)

func _process(delta: float) -> void:
	timer += delta
	if timer >= anim_interval:
		timer = 0.0
		current_frame = 1 if current_frame == 0 else 0
		refresh_heart_textures()

func update_health(new_hp: int) -> void:
	current_hp = clamp(new_hp, 0, max_hp)
	
	for child in get_children():
		child.queue_free()
		
	for i in range(max_hp):
		var heart = TextureRect.new()
		heart.custom_minimum_size = heart_size
		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		heart.position = Vector2(i * (heart_size.x + spacing), 0)
		add_child(heart)
		
	refresh_heart_textures()

func refresh_heart_textures() -> void:
	var hearts = get_children()
	for i in range(hearts.size()):
		if i < current_hp:
			if heart_full_frames.size() >= 2:
				hearts[i].texture = heart_full_frames[current_frame]
			elif not heart_full_frames.is_empty():
				hearts[i].texture = heart_full_frames[0]
		else:
			if heart_empty_frames.size() >= 2:
				hearts[i].texture = heart_empty_frames[current_frame]
			elif not heart_empty_frames.is_empty():
				hearts[i].texture = heart_empty_frames[0]

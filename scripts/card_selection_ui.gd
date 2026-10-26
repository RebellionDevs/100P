extends Control

@onready var blur_overlay: ColorRect = $BlurOverlay

@export var card_size: Vector2 = Vector2(240, 340)
@export var card_spacing: float = 40.0

var active_cards: Array[TextureRect] = []

func _ready() -> void:
	visible = false
	blur_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	blur_overlay.gui_input.connect(_on_blur_gui_input)

func open_cards() -> void:
	visible = true
	clear_cards()
		
	var hand_size = GameManager.hand.size()
	if hand_size == 0:
		return
		
	var total_width = (hand_size * card_size.x) + ((hand_size - 1) * card_spacing)
	var screen_size = get_viewport_rect().size
	var start_x = (screen_size.x - total_width) / 2.0
	var start_y = (screen_size.y - card_size.y) / 2.0
	
	for i in range(hand_size):
		var card_name = GameManager.hand[i]
		
		var card_rect = TextureRect.new()
		card_rect.size = card_size
		card_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		card_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		card_rect.mouse_filter = Control.MOUSE_FILTER_STOP

		var normal_path = "res://assets/sprites/cards/%s.png" % card_name.to_lower()
		var desc_path = "res://assets/sprites/cards/%s_description.png" % card_name.to_lower()

		var tex_normal = load(normal_path) if ResourceLoader.exists(normal_path) else null
		var tex_desc = load(desc_path) if ResourceLoader.exists(desc_path) else tex_normal

		card_rect.texture = tex_normal

		card_rect.gui_input.connect(func(event: InputEvent):
			if event is InputEventMouseButton and event.pressed:
				if event.button_index == MOUSE_BUTTON_LEFT:
					_on_card_left_clicked(card_name)
					get_viewport().set_input_as_handled()
				elif event.button_index == MOUSE_BUTTON_RIGHT:
					if tex_desc:
						if card_rect.texture == tex_normal:
							card_rect.texture = tex_desc
						else:
							card_rect.texture = tex_normal
					get_viewport().set_input_as_handled()
		)
		
		var pos_x = start_x + i * (card_size.x + card_spacing)
		card_rect.position = Vector2(pos_x, start_y)
		
		add_child(card_rect)
		active_cards.append(card_rect)

func hide_cards() -> void:
	visible = false
	clear_cards()

func clear_cards() -> void:
	for card in active_cards:
		if is_instance_valid(card):
			card.queue_free()
	active_cards.clear()

func _on_blur_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		hide_cards()

func _on_card_left_clicked(card_name: String) -> void:
	print("Выбрана карта: ", card_name)
	hide_cards()

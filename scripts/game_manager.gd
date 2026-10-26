extends Node

enum State { PLAYER_TURN, BULLET_FLYING, AIMING_CARD_SHOT, WAITING_FOR_CARD, ENEMY_TURN }
var current_state: State = State.PLAYER_TURN

var active_bullet: Node2D = null
var has_frozen_bullet: bool = false
var selected_card: String = ""

var deck: Array[String] = []
var discard_pile: Array[String] = []
var hand: Array[String] = []

func _ready() -> void:
	init_deck()

func init_deck() -> void:
	deck.clear()
	discard_pile.clear()
	hand.clear()
	
	var group_a = ["Sinusoid", "Parabola", "Tangent"]
	for card in group_a:
		for i in range(10):
			deck.append(card)
			
	var group_b = ["Folium", "Beurnulli", "Archimedean"]
	for card in group_b:
		for i in range(7):
			deck.append(card)
			
	for i in range(3):
		deck.append("Singularity")
		
	deck.shuffle()
	draw_hand()

func draw_hand() -> void:
	hand.clear()
	for i in range(3):
		if deck.is_empty():
			if discard_pile.is_empty():
				break
			deck = discard_pile.duplicate()
			discard_pile.clear()
			deck.shuffle()
		if not deck.is_empty():
			hand.append(deck.pop_back())

func discard_current_hand() -> void:
	for card in hand:
		discard_pile.append(card)
	hand.clear()

func on_bullet_hit_function_wall(bullet: Node2D, collision_pos: Vector2) -> void:
	active_bullet = bullet
	has_frozen_bullet = true
	start_enemy_turn()

func on_bullet_destroyed() -> void:
	active_bullet = null
	has_frozen_bullet = false
	start_enemy_turn()

func start_enemy_turn() -> void:
	current_state = State.ENEMY_TURN
	await get_tree().create_timer(1.0).timeout
	start_player_turn()

func start_player_turn() -> void:
	current_state = State.PLAYER_TURN
	if has_frozen_bullet and active_bullet:
		current_state = State.WAITING_FOR_CARD

func apply_card_and_shoot_from_wall(card_type: String, new_direction: Vector2) -> void:
	if current_state != State.WAITING_FOR_CARD or not active_bullet:
		return
		
	has_frozen_bullet = false
	active_bullet.unfreeze_with_function(card_type, new_direction)
	current_state = State.BULLET_FLYING

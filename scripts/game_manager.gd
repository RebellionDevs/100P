extends Node

enum State { 
	PLAYER_1_TURN, 
	PLAYER_2_TURN, 
	BULLET_FLYING,
	ENEMY_TURN,
	WAITING_FOR_CARD_P1, 
	WAITING_FOR_CARD_P2, 
	AIMING_CARD_SHOT_P1, 
	AIMING_CARD_SHOT_P2, 
	GAME_OVER 
}
var current_state: State = State.PLAYER_1_TURN

var p1_active_bullet: Node2D = null
var p2_active_bullet: Node2D = null

var active_bullet: Node2D:
	get:
		return p1_active_bullet if active_player == 1 else p2_active_bullet
	set(val):
		if active_player == 1:
			p1_active_bullet = val
		else:
			p2_active_bullet = val

var has_frozen_bullet: bool:
	get:
		return (p1_active_bullet != null) or (p2_active_bullet != null)

var active_player: int = 1
var is_enemy_bullet_flying: bool = false
var selected_card: String = ""

var p1_max_hp: int = 3
var p1_hp: int = 3
var p2_max_hp: int = 3
var p2_hp: int = 3

var deck: Array[String] = []
var discard_pile: Array[String] = []
var hand: Array[String] = []

func _ready() -> void:
	reset_game_state()

func reset_game_state() -> void:
	current_state = State.PLAYER_1_TURN
	p1_active_bullet = null
	p2_active_bullet = null
	active_player = 1
	is_enemy_bullet_flying = false
	selected_card = ""
	p1_hp = p1_max_hp
	p2_hp = p2_max_hp
	update_ui_health()
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
	if deck.is_empty() and discard_pile.is_empty() and hand.is_empty():
		trigger_game_over("Game Over (Deck Empty)")
		return

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
	if not is_instance_valid(bullet):
		return

	if bullet.is_in_group("player_1_bullet"):
		p1_active_bullet = bullet
		active_player = 2
		current_state = State.PLAYER_2_TURN
	elif bullet.is_in_group("player_2_bullet"):
		p2_active_bullet = bullet
		active_player = 1
		current_state = State.PLAYER_1_TURN
	else:
		is_enemy_bullet_flying = false
		advance_turn_order()

func on_bullet_destroyed() -> void:
	advance_turn_order()

func advance_turn_order() -> void:
	if current_state == State.GAME_OVER:
		return

	if active_player == 1:
		active_player = 2
		current_state = State.PLAYER_2_TURN
	else:
		active_player = 1
		current_state = State.PLAYER_1_TURN

func apply_card_and_shoot_from_wall(card_type: String, new_direction: Vector2) -> void:
	if active_player == 1 and is_instance_valid(p1_active_bullet):
		p1_active_bullet.unfreeze_with_function(card_type, new_direction)
		p1_active_bullet = null
		current_state = State.BULLET_FLYING
	elif active_player == 2 and is_instance_valid(p2_active_bullet):
		p2_active_bullet.unfreeze_with_function(card_type, new_direction)
		p2_active_bullet = null
		current_state = State.BULLET_FLYING

func take_p1_damage(amount: int) -> void:
	p1_hp = max(0, p1_hp - amount)
	update_ui_health()
	if p1_hp <= 0:
		trigger_game_over("Player 2 Wins!")

func take_p2_damage(amount: int) -> void:
	p2_hp = max(0, p2_hp - amount)
	update_ui_health()
	if p2_hp <= 0:
		trigger_game_over("Player 1 Wins!")

func update_ui_health() -> void:
	var tree = get_tree()
	if not tree: return
	
	var p1_ui = tree.current_scene.find_child("PlayerHealth", true, false)
	if p1_ui and p1_ui.has_method("update_health"):
		p1_ui.update_health(p1_hp)
		
	var p2_ui = tree.current_scene.find_child("EnemyHealth", true, false)
	if p2_ui and p2_ui.has_method("update_health"):
		p2_ui.update_health(p2_hp)

func trigger_game_over(reason: String) -> void:
	current_state = State.GAME_OVER
	var end_ui = get_tree().current_scene.find_child("GameOverUI", true, false)
	if end_ui:
		if end_ui.has_method("show_game_over"):
			end_ui.show_game_over(reason)
		elif end_ui.has_method("show"):
			end_ui.show()

func handle_bullet_hit_entity(bullet: Node2D, collider: Node) -> void:
	var hit_player := 0
	if collider.is_in_group("player_1"):
		hit_player = 1
	elif collider.is_in_group("player_2"):
		hit_player = 2

	if hit_player != 0:
		var damage_player = hit_player
		if bullet is Bullet and bullet.is_under_function:
			if (bullet.is_in_group("player_1_bullet") and hit_player == 1) or \
					(bullet.is_in_group("player_2_bullet") and hit_player == 2):
				damage_player = 2 if hit_player == 1 else 1

		if damage_player == 1:
			take_p1_damage(1)
		else:
			take_p2_damage(1)
			
	if is_instance_valid(bullet):
		bullet.queue_free()
		
	if bullet == p1_active_bullet:
		p1_active_bullet = null
	if bullet == p2_active_bullet:
		p2_active_bullet = null
		
	advance_turn_order()

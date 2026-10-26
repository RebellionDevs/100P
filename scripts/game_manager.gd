extends Node

enum State { PLAYER_TURN, BULLET_FLYING, AIMING_CARD_SHOT, WAITING_FOR_CARD, ENEMY_TURN, GAME_OVER }
var current_state: State = State.PLAYER_TURN

var active_bullet: Node2D = null
var has_frozen_bullet: bool = false
var selected_card: String = ""

var player_max_hp: int = 3
var player_hp: int = 3
var enemy_max_hp: int = 3
var enemy_hp: int = 3

var deck: Array[String] = []
var discard_pile: Array[String] = []
var hand: Array[String] = []

func _ready() -> void:
	player_hp = player_max_hp
	enemy_hp = enemy_max_hp
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
		trigger_game_over("Карты в колоде окончательно кончились!")
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
	active_bullet = bullet
	has_frozen_bullet = true
	start_enemy_turn()

func on_bullet_destroyed() -> void:
	active_bullet = null
	has_frozen_bullet = false
	start_enemy_turn()

func take_player_damage(amount: int) -> void:
	player_hp = max(0, player_hp - amount)
	update_ui_health()
	if player_hp <= 0:
		trigger_game_over("Твое ХП кончилось. Поражение!")

func take_enemy_damage(amount: int) -> void:
	enemy_hp = max(0, enemy_hp - amount)
	update_ui_health()
	if enemy_hp <= 0:
		trigger_game_over("ХП противника кончилось. Победа!")

func update_ui_health() -> void:
	var tree = get_tree()
	if not tree: return
	
	var player_health_ui = tree.current_scene.find_child("PlayerHealth", true, false)
	if player_health_ui and player_health_ui.has_method("update_health"):
		player_health_ui.update_health(player_hp)
		
	var enemy_health_ui = tree.current_scene.find_child("EnemyHealth", true, false)
	if enemy_health_ui and enemy_health_ui.has_method("update_health"):
		enemy_health_ui.update_health(enemy_hp)

func trigger_game_over(reason: String) -> void:
	current_state = State.GAME_OVER
	
	var end_ui = get_tree().current_scene.find_child("GameOverUI", true, false)
	if end_ui and end_ui.has_method("show"):
		end_ui.show()

func start_enemy_turn() -> void:
	current_state = State.ENEMY_TURN
	await get_tree().create_timer(1.0).timeout
	if current_state != State.GAME_OVER:
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

func handle_bullet_hit_entity(bullet: Node2D, collider: Node) -> void:
	var is_func = bullet.get("is_under_function") == true
	
	if collider.is_in_group("player"):
		if is_func:
			take_enemy_damage(1)
		else:
			take_player_damage(1)
			
	elif collider.is_in_group("enemy"):
			take_player_damage(1)
			
	if current_state != State.GAME_OVER:
		start_enemy_turn()

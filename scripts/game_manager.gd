extends Node

enum State { PLAYER_TURN, BULLET_FLYING, WAITING_FOR_CARD, ENEMY_TURN }
var current_state: State = State.PLAYER_TURN

var active_bullet: Node2D = null
var has_frozen_bullet: bool = false

func _ready() -> void:
	pass

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

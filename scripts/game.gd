extends Node2D

@onready var current_level: Node2D = $CurrentLevel
@onready var game_state_label: Label = $UI/GameState
@onready var card_left_label: Label = $UI/CardLeft

func _ready() -> void:
	load_level("res://scenes/level-1.tscn")

func _process(delta: float) -> void:
	match GameManager.current_state:
		GameManager.State.PLAYER_1_TURN:
			game_state_label.text = "P1 Turn"
		GameManager.State.PLAYER_2_TURN:
			game_state_label.text = "P2 Turn"
		GameManager.State.BULLET_FLYING:
			game_state_label.text = "Bullet Flying"
		GameManager.State.WAITING_FOR_CARD_P1:
			game_state_label.text = "P1: Waiting for Card"
		GameManager.State.WAITING_FOR_CARD_P2:
			game_state_label.text = "P2: Waiting for Card"
		GameManager.State.GAME_OVER:
			game_state_label.text = "Game Over"
			
	card_left_label.text = "Cards Left: " + str(GameManager.deck.size())

func load_level(path: String) -> void:
	var level_scene = load(path) as PackedScene
	if level_scene:
		var level_instance = level_scene.instantiate()
		current_level.add_child(level_instance)

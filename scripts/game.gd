extends Node2D

@onready var current_level: Node2D = $CurrentLevel

func _ready() -> void:
	load_level("res://scenes/level-1.tscn")

func load_level(path: String) -> void:
	var level_scene = load(path) as PackedScene
	if level_scene:
		var level_instance = level_scene.instantiate()
		current_level.add_child(level_instance)

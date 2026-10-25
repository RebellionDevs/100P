class_name Player
extends Node2D

@export var bullet_scene: PackedScene
@export var shoot_speed: float = 700.0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		shoot()

func shoot() -> void:
	
	var bullet = bullet_scene.instantiate() as CharacterBody2D
	if not bullet:
		return
		
	bullet.global_position = global_position
	
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	
	bullet.velocity = direction * shoot_speed
	
	get_tree().current_scene.add_child(bullet)

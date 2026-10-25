class_name Bullet
extends CharacterBody2D

@export var speed: float = 600.0
@export var max_bounces: int = 5

var bounce_count: int = 0
var is_frozen: bool = false
var current_function_mode: String = ""

func _ready() -> void:
	add_to_group("bullet")

func _physics_process(delta: float) -> void:
	if is_frozen:
		return
		
	var collision = move_and_collide(velocity * delta)
	if collision:
		_handle_collision(collision)

func _handle_collision(collision: KinematicCollision2D) -> void:
	var collider = collision.get_collider()
	var normal = collision.get_normal()
	
	if collider:
		if collider.is_in_group("function_wall"):
			_freeze_in_wall(collision)
			return

		if collider.is_in_group("enemy"):
			collider.queue_free()
			queue_free()
			GameManager.on_bullet_destroyed()
			return

	bounce_count += 1
	if bounce_count > max_bounces:
		queue_free()
		GameManager.on_bullet_destroyed()
		return
	
	velocity = velocity.bounce(normal)

func _freeze_in_wall(collision: KinematicCollision2D) -> void:
	is_frozen = true
	velocity = Vector2.ZERO
	global_position = collision.get_position()
	
	GameManager.on_bullet_hit_function_wall(self, global_position)

func unfreeze_with_function(card_name: String, new_direction: Vector2) -> void:
	current_function_mode = card_name
	bounce_count = 0
	is_frozen = false
	
	velocity = new_direction.normalized() * speed

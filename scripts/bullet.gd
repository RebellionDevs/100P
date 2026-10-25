class_name Bullet
extends CharacterBody2D

# Настройки скорости и лимита рикошетов
@export var speed: float = 600.0
@export var max_bounces: int = 5

var bounce_count: int = 0

func _ready() -> void:
	add_to_group("bullet")

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		_handle_bounce(collision)

func _handle_bounce(collision: KinematicCollision2D) -> void:
	var collider = collision.get_collider()
	var normal = collision.get_normal()
	
	if collider and collider.is_in_group("function_wall"):
		bounce_count = 0
		_apply_function_bounce(collision, normal)
		return
		
	bounce_count += 1
	if bounce_count > max_bounces:
		queue_free()
		return
		
	velocity = velocity.bounce(normal)

# TEST
func _apply_function_bounce(collision: KinematicCollision2D, normal: Vector2) -> void:
	var hit_pos = collision.get_position()
	var base_bounce = velocity.bounce(normal)
	
	var math_modifier = sin(hit_pos.x * 0.05) * 200.0
	velocity = base_bounce + Vector2(0, math_modifier)

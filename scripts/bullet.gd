class_name Bullet
extends CharacterBody2D

@export var speed: float = 1200.0
@export var max_bounces: int = 5

var bounce_count: int = 0
var is_under_function: bool = false

func _ready() -> void:
	add_to_group("bullet")

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	if collision:
		_handle_collision(collision)

func _handle_collision(collision: KinematicCollision2D) -> void:
	var collider = collision.get_collider()
	var normal = collision.get_normal()
	
	if collider:
		if collider.is_in_group("player"):
			_handle_player_hit(collider)
			return

		if collider.is_in_group("function_wall"):
			bounce_count = 0
			is_under_function = true
			_apply_function_bounce(collision, normal)
			return

	bounce_count += 1
	if bounce_count > max_bounces:
		queue_free()
		return
	
	velocity = velocity.bounce(normal)

func _handle_player_hit(player: Node2D) -> void:
	if not is_under_function:
		if player.has_method("take_damage"):
			player.take_damage(1)
	else:
		# enemy take damage at this block
		pass
		
	queue_free()

func _apply_function_bounce(collision: KinematicCollision2D, normal: Vector2) -> void:
	var hit_pos = collision.get_position()
	var base_bounce = velocity.bounce(normal)
	var math_modifier = sin(hit_pos.x * 0.05) * 200.0
	velocity = base_bounce + Vector2(0, math_modifier)

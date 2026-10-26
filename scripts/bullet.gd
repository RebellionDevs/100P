class_name Bullet
extends CharacterBody2D

var path_points: PackedVector2Array = []
var current_point_index: int = 1
var move_speed: float = 1700.0
var is_following_path: bool = false
var is_frozen: bool = false
var ends_on_wall: bool = false
var is_under_function: bool = false

func setup_path(points: PackedVector2Array, speed: float, hits_wall_at_end: bool, under_func: bool = false) -> void:
	path_points = points
	move_speed = speed
	ends_on_wall = hits_wall_at_end
	current_point_index = 1
	is_following_path = true
	is_frozen = false
	is_under_function = under_func

func _physics_process(delta: float) -> void:
	if is_frozen or not is_following_path:
		return
		
	if path_points.is_empty() or current_point_index >= path_points.size():
		if ends_on_wall:
			is_frozen = true
			velocity = Vector2.ZERO
			GameManager.on_bullet_hit_function_wall(self, global_position)
		else:
			queue_free()
			GameManager.on_bullet_destroyed()
		return
		
	var target_pos = path_points[current_point_index]
	var direction = target_pos - global_position
	var distance = direction.length()
	var step = min(move_speed * delta, distance)
	
	var collision = move_and_collide(direction.normalized() * step)
	if collision:
		var collider = collision.get_collider()
		if collider:
			if collider.is_in_group("function_wall"):
				is_frozen = true
				velocity = Vector2.ZERO
				GameManager.on_bullet_hit_function_wall(self, collision.get_position())
				return
			elif collider.is_in_group("player") or collider.is_in_group("enemy"):
				GameManager.handle_bullet_hit_entity(self, collider)
				queue_free()
				return
	
	if distance <= step:
		global_position = target_pos
		current_point_index += 1

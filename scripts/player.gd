class_name Player
extends Node2D

@export var bullet_scene: PackedScene
@export var shoot_speed: float = 1700.0
@export var max_prediction: int = 5

@onready var gun_pivot: Node2D = $GunPivot
@onready var muzzle: Marker2D = $GunPivot/Muzzle
@onready var trajectory_line: Line2D = $TrajectoryLine

func can_shoot() -> bool:
	var ui = get_tree().current_scene.find_child("CardSelectionUI", true, false)
	if ui and ui.visible:
		return false
	return GameManager.current_state == GameManager.State.PLAYER_TURN or GameManager.current_state == GameManager.State.WAITING_FOR_CARD

func _process(_delta: float) -> void:
	if not can_shoot() or not is_mouse_in_bounds():
		trajectory_line.points = []
		return
	
	var mouse_pos = get_global_mouse_position()
	var direction = mouse_pos - global_position
	gun_pivot.rotation = direction.angle() + PI
	
	update_trajectory()

func is_mouse_in_bounds() -> bool:
	var space_state = get_world_2d().direct_space_state
	var point_query = PhysicsPointQueryParameters2D.new()
	point_query.position = get_global_mouse_position()
	point_query.collide_with_areas = true
	
	var results = space_state.intersect_point(point_query)
	for res in results:
		var collider = res.collider
		if collider and collider.is_in_group("level_bounds"):
			return true
	return false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not is_mouse_in_bounds():
			return
			
		if GameManager.current_state == GameManager.State.PLAYER_TURN:
			shoot()
		elif GameManager.current_state == GameManager.State.WAITING_FOR_CARD:
			shoot_new_bullet_and_reshuffle()

func update_trajectory() -> void:
	var space_state = get_world_2d().direct_space_state
	var points: Array[Vector2] = []
	var current_pos = muzzle.global_position
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - muzzle.global_position).normalized()
	var current_velocity = direction * shoot_speed
	
	points.append(to_local(muzzle.global_position)) 
	
	for i in range(max_prediction):
		var target_pos = current_pos + current_velocity.normalized() * 2000.0
		
		var ray_query = PhysicsRayQueryParameters2D.create(current_pos, target_pos)
		var result = space_state.intersect_ray(ray_query)
		
		if result:
			var hit_pos = result.position
			var normal = result.normal
			var collider = result.collider
			
			points.append(to_local(hit_pos))
			
			if collider and collider.is_in_group("function_wall"):
				var base_bounce = current_velocity.bounce(normal)
				var math_modifier = sin(hit_pos.x * 0.05) * 200.0
				current_velocity = base_bounce + Vector2(0, math_modifier)
			else:
				current_velocity = current_velocity.bounce(normal)

			current_pos = hit_pos + normal * 1.0
		else:
			points.append(to_local(target_pos))
			break
			
	trajectory_line.points = points

func shoot() -> void:
	if not bullet_scene or GameManager.current_state != GameManager.State.PLAYER_TURN:
		return
		
	if GameManager.active_bullet and is_instance_valid(GameManager.active_bullet):
		GameManager.active_bullet.queue_free()
	GameManager.active_bullet = null
	GameManager.has_frozen_bullet = false
		
	var bullet = bullet_scene.instantiate() as CharacterBody2D
	bullet.add_to_group("player_bullet")
	if not bullet:
		return
		
	bullet.global_position = muzzle.global_position
	
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - muzzle.global_position).normalized()
	bullet.velocity = direction * shoot_speed
	
	get_tree().current_scene.add_child(bullet)
	GameManager.current_state = GameManager.State.BULLET_FLYING

func shoot_new_bullet_and_reshuffle() -> void:
	if GameManager.current_state != GameManager.State.WAITING_FOR_CARD:
		return
		
	if GameManager.active_bullet and is_instance_valid(GameManager.active_bullet):
		GameManager.active_bullet.queue_free()
	
	GameManager.active_bullet = null
	GameManager.has_frozen_bullet = false
	
	GameManager.discard_current_hand()
	GameManager.draw_hand()
	
	if not bullet_scene:
		return
		
	var bullet = bullet_scene.instantiate() as CharacterBody2D
	bullet.add_to_group("player_bullet")
	if not bullet:
		return
		
	bullet.global_position = muzzle.global_position
	
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - muzzle.global_position).normalized()
	bullet.velocity = direction * shoot_speed
	
	get_tree().current_scene.add_child(bullet)
	GameManager.current_state = GameManager.State.BULLET_FLYING

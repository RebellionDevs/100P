class_name PlayerTwo
extends StaticBody2D

@export var bullet_scene: PackedScene
@export var shoot_speed: float = 1700.0
@export var bullet_max_bounces: int = 6
@export var preview_bounces: int = 5

@onready var gun_pivot: Node2D = $GunPivot
@onready var muzzle: Marker2D = $GunPivot/Muzzle
@onready var trajectory_line: Line2D = $TrajectoryLine

var card_param: float = 1.0
var singularity_pos: Vector2 = Vector2.ZERO
var singularity_point_set: bool = false
var current_path: PackedVector2Array = []
var path_ends_on_function_wall: bool = false

func _ready() -> void:
	trajectory_line.top_level = true

func can_shoot() -> bool:
	return GameManager.current_state == GameManager.State.PLAYER_2_TURN or GameManager.current_state == GameManager.State.AIMING_CARD_SHOT_P2

func _process(_delta: float) -> void:
	if not can_shoot():
		trajectory_line.clear_points()
		return
	
	if GameManager.current_state == GameManager.State.PLAYER_2_TURN:
		if not is_mouse_in_bounds():
			trajectory_line.clear_points()
			return
		var mouse_pos = get_global_mouse_position()
		gun_pivot.rotation = (mouse_pos - global_position).angle()
		update_normal_trajectory()
	else:
		update_card_trajectory_from_wall()

func is_mouse_in_bounds() -> bool:
	var space_state = get_world_2d().direct_space_state
	var point_query = PhysicsPointQueryParameters2D.new()
	point_query.position = get_global_mouse_position()
	point_query.collide_with_areas = true

	for result in space_state.intersect_point(point_query):
		var collider = result.collider
		if collider and collider.is_in_group("level_bounds"):
			return true
	return false

func update_normal_trajectory() -> void:
	var space_state = get_world_2d().direct_space_state
	var full_path: PackedVector2Array = []
	var preview_path: PackedVector2Array = []
	var current_pos = muzzle.global_position
	var mouse_pos = get_global_mouse_position()
	var current_velocity = (mouse_pos - muzzle.global_position).normalized() * shoot_speed
	
	full_path.append(muzzle.global_position)
	preview_path.append(muzzle.global_position)
	
	var bounce_count = 0
	for i in range(100):
		var target_pos = current_pos + current_velocity.normalized() * 2000.0
		var ray_query = PhysicsRayQueryParameters2D.create(current_pos, target_pos)
		ray_query.collision_mask = 0xFFFFFFFF
		var result = space_state.intersect_ray(ray_query)
		
		if result:
			var hit_pos = result.position
			var normal = result.normal
			var collider = result.collider
			
			if collider and collider.is_in_group("function_wall"):
				full_path.append(hit_pos)
				if bounce_count < preview_bounces:
					preview_path.append(hit_pos)
				break
			
			full_path.append(hit_pos)
			if bounce_count < preview_bounces:
				preview_path.append(hit_pos)
			
			bounce_count += 1
			if bounce_count >= bullet_max_bounces:
				break
				
			current_velocity = current_velocity.bounce(normal)
			current_pos = hit_pos + normal * 1.0
		else:
			full_path.append(target_pos)
			if bounce_count < preview_bounces:
				preview_path.append(target_pos)
			break
			
	current_path = full_path
	trajectory_line.points = preview_path

func _unhandled_input(event: InputEvent) -> void:
	if not can_shoot():
		return

	if GameManager.current_state == GameManager.State.AIMING_CARD_SHOT_P2:
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				card_param = clampf(card_param + 0.2, 0.2, 5.0)
				get_viewport().set_input_as_handled()
				return
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				card_param = clampf(card_param - 0.2, 0.2, 5.0)
				get_viewport().set_input_as_handled()
				return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not is_mouse_in_bounds():
			return
		if GameManager.current_state == GameManager.State.AIMING_CARD_SHOT_P2:
			if GameManager.selected_card == "Singularity" and not singularity_point_set:
				singularity_pos = get_global_mouse_position()
				singularity_point_set = true
				if GameManager.active_bullet and is_instance_valid(GameManager.active_bullet):
					GameManager.active_bullet.global_position = singularity_pos
			else:
				shoot_from_wall()
		else:
			shoot()

func update_card_trajectory_from_wall() -> void:
	if GameManager.selected_card == "Singularity" and not singularity_point_set:
		trajectory_line.clear_points()
		current_path.clear()
		return

	var space_state = get_world_2d().direct_space_state
	var full_path: PackedVector2Array = []
	var preview_path: PackedVector2Array = []
	var origin_pos = singularity_pos if GameManager.selected_card == "Singularity" else (
		GameManager.active_bullet.global_position if GameManager.active_bullet else global_position
	)
	var current_pos = origin_pos
	var direction = (get_global_mouse_position() - current_pos).normalized()
	var current_velocity = direction * shoot_speed
	var virtual_time := 0.0
	var dt := 0.04
	var bounce_count := 0
	path_ends_on_function_wall = false
	full_path.append(current_pos)
	preview_path.append(current_pos)

	for i in range(2000):
		virtual_time += dt
		current_velocity = apply_card_math(current_velocity, virtual_time, GameManager.selected_card, dt, card_param)
		var target_pos = current_pos + current_velocity * dt
		var ray_query = PhysicsRayQueryParameters2D.create(current_pos, target_pos)
		ray_query.collision_mask = 0xFFFFFFFF
		var result = space_state.intersect_ray(ray_query)

		if result:
			var hit_pos: Vector2 = result.position
			var normal: Vector2 = result.normal
			var collider = result.collider
			full_path.append(hit_pos)
			if bounce_count < preview_bounces:
				preview_path.append(hit_pos)
			if collider and collider.is_in_group("function_wall"):
				path_ends_on_function_wall = true
				break
			bounce_count += 1
			if bounce_count >= bullet_max_bounces:
				break
			current_velocity = current_velocity.bounce(normal)
			current_pos = hit_pos + normal
		else:
			current_pos = target_pos
			full_path.append(current_pos)
			if bounce_count < preview_bounces:
				preview_path.append(current_pos)
			if current_pos.distance_to(origin_pos) > 6000.0:
				break

	current_path = full_path
	trajectory_line.points = preview_path

func apply_card_math(vel: Vector2, t: float, card_name: String, dt: float, param: float) -> Vector2:
	var perp = Vector2(-vel.y, vel.x).normalized()
	match card_name:
		"Sinusoid":
			vel += perp * sin(t * 15.0 * param) * 3000.0 * dt
		"Parabola":
			vel += Vector2(0, 4000.0 * param) * dt
		"Tangent":
			var phase = fmod(t * param, 0.5)
			if phase > 0.22 and phase < 0.28:
				vel = vel.rotated(deg_to_rad(45.0 * sign(vel.x)))
		"Archimedean":
			vel = vel.rotated(deg_to_rad(180.0 * param) * dt)
		"Beurnulli":
			vel += perp * cos(t * 10.0 * param) * 2500.0 * dt
		"Folium":
			vel += perp * (sin(t * 6.0) * cos(t * 6.0)) * 2500.0 * param * dt
		"Singularity":
			vel += vel.normalized() * (2000.0 * param) * dt
	return vel

func shoot_from_wall() -> void:
	if GameManager.current_state != GameManager.State.AIMING_CARD_SHOT_P2:
		return
	if GameManager.active_bullet and is_instance_valid(GameManager.active_bullet):
		var bullet = GameManager.active_bullet
		if GameManager.selected_card == "Singularity":
			bullet.global_position = singularity_pos
		bullet.setup_path(current_path, shoot_speed, path_ends_on_function_wall, true)
	GameManager.active_bullet = null
	GameManager.selected_card = ""
	singularity_point_set = false
	card_param = 1.0
	trajectory_line.clear_points()
	GameManager.current_state = GameManager.State.BULLET_FLYING

func shoot() -> void:
	if not bullet_scene or not can_shoot():
		return
		
	var bullet = bullet_scene.instantiate() as CharacterBody2D
	if not bullet:
		return

	bullet.add_to_group("player_2_bullet")
	bullet.add_to_group("bullet")
	
	bullet.global_position = muzzle.global_position
	bullet.setup_path(current_path, shoot_speed, false, false)
	
	get_tree().current_scene.add_child(bullet)
	GameManager.current_state = GameManager.State.BULLET_FLYING

class_name Enemy
extends StaticBody2D

@export var bullet_scene: PackedScene
@export var shoot_speed: float = 1700.0
@export var bullet_max_bounces: int = 6

@onready var gun_pivot: Node2D = $GunPivot
@onready var muzzle: Marker2D = $GunPivot/Muzzle

var available_cards: Array[String] = ["Sinusoid", "Parabola", "Tangent", "Archimedean"]

var is_thinking: bool = false

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if GameManager.current_state == GameManager.State.ENEMY_TURN and not is_thinking:
		start_enemy_turn()
	pass

func start_enemy_turn() -> void:
	is_thinking = true
	
	# Пауза для анимации раздумий (теперь без крашей через .timeout)
	await get_tree().create_timer(0.5).timeout
	
	# Ждем асинхронный расчет читера, чтобы не вешать процессор
	var best_shot = await find_cheating_shot()
	
	if best_shot.success:
		gun_pivot.rotation = best_shot.angle
		shoot(best_shot.card, best_shot.param, best_shot.path)
	else:
		shoot("Parabola", 1.0, [])
		
	is_thinking = false

func find_cheating_shot() -> Dictionary:
	var space_state = get_world_2d().direct_space_state
	var iterations_count = 0
	
	for card in available_cards:
		var param = 0.5
		while param <= 3.0:
			# Шаг в 3 градуса (золотая середина между точностью и нагрузкой на проц)
			var angle_deg = 0.0
			while angle_deg < 360.0:
				var test_angle = deg_to_rad(angle_deg)
				var test_dir = Vector2.RIGHT.rotated(test_angle)
				
				var simulated_path = simulate_trajectory(muzzle.global_position, test_dir, card, param, space_state)
				
				if not simulated_path.is_empty():
					var end_pos = simulated_path[simulated_path.size() - 1]
					if end_pos.distance_to(global_position) < 40.0:
						return {
							"success": true,
							"angle": test_angle,
							"card": card,
							"param": param,
							"path": simulated_path
						}
				
				angle_deg += 3.0
				iterations_count += 1
				
				# КАЖДЫЕ 30 проверок отдаем кадр системе! 
				# Это спасет процессор от перегрева, а игру от фризов.
				if iterations_count % 30 == 0:
					await get_tree().process_frame
					
			param += 0.5
			
	return {"success": false, "angle": 0.0, "card": "Parabola", "param": 1.0, "path": []}

func simulate_trajectory(start_pos: Vector2, direction: Vector2, card_name: String, param: float, space_state: PhysicsDirectSpaceState2D) -> PackedVector2Array:
	var full_path: PackedVector2Array = []
	var current_pos = start_pos
	var current_velocity = direction * shoot_speed
	
	full_path.append(start_pos)
	var virtual_time = 0.0
	var dt = 0.04
	var bounce_count = 0
	
	# Снизили с 2000 до 500 шагов — пуля столько не живет, а проц скажет спасибо
	for i in range(500):
		virtual_time += dt
		current_velocity = apply_card_math(current_velocity, virtual_time, card_name, dt, param)
		
		var target_pos = current_pos + current_velocity * dt
		var ray_query = PhysicsRayQueryParameters2D.create(current_pos, target_pos)
		ray_query.collision_mask = 0xFFFFFFFF
		var result = space_state.intersect_ray(ray_query)
		
		if result:
			var hit_pos = result.position
			var normal = result.normal
			var collider = result.collider
			
			if collider and collider.is_in_group("function_wall"):
				full_path.append(hit_pos)
				break
				
			full_path.append(hit_pos)
			bounce_count += 1
			if bounce_count >= bullet_max_bounces:
				break
				
			current_velocity = current_velocity.bounce(normal)
			current_pos = hit_pos + normal * 1.0
		else:
			current_pos = target_pos
			full_path.append(current_pos)
			if current_pos.distance_to(start_pos) > 6000.0:
				break
				
	return full_path

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
	return vel

func shoot(card_name: String, param: float, path: PackedVector2Array) -> void:
	if not bullet_scene:
		return
		
	var bullet = bullet_scene.instantiate() as CharacterBody2D
	bullet.add_to_group("bullet")
	bullet.add_to_group("enemy_bullet")
	
	bullet.global_position = muzzle.global_position
	
	if not path.is_empty():
		bullet.setup_path(path, shoot_speed, true, true)
	else:
		var fallback_path = PackedVector2Array([muzzle.global_position, muzzle.global_position + Vector2.RIGHT * 1000.0])
		bullet.setup_path(fallback_path, shoot_speed, false, false)
		
	get_tree().current_scene.add_child(bullet)
	
	# Обязательно фиксируем, что летит пуля бота
	GameManager.is_enemy_bullet_flying = true
	GameManager.current_state = GameManager.State.BULLET_FLYING

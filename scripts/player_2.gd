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
var current_path: PackedVector2Array = []

func _ready() -> void:
	trajectory_line.top_level = true

func can_shoot() -> bool:
	return GameManager.current_state == GameManager.State.PLAYER_2_TURN

func _process(_delta: float) -> void:
	if not can_shoot():
		trajectory_line.clear_points()
		return
	
	if not is_mouse_in_bounds():
		trajectory_line.clear_points()
		return

	var mouse_pos = get_global_mouse_position()
	gun_pivot.rotation = (mouse_pos - global_position).angle()
	update_normal_trajectory()

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
		
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_mouse_in_bounds():
			shoot()

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

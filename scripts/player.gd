class_name Player
extends Node2D

@export var bullet_scene: PackedScene
@export var shoot_speed: float = 700.0
@export var max_prediction: int = 5

@onready var gun_pivot: Node2D = $GunPivot
@onready var muzzle: Marker2D = $GunPivot/Muzzle
@onready var trajectory_line: Line2D = $TrajectoryLine

func _process(_delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	
	var direction = mouse_pos - global_position
	gun_pivot.rotation = direction.angle() + PI
	
	update_trajectory()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		shoot()
		
func update_trajectory() -> void:
	var points: Array[Vector2] = []
	var current_pos = muzzle.global_position
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - muzzle.global_position).normalized()
	var current_velocity = direction * shoot_speed
	
	points.append(to_local(muzzle.global_position)) 
	
	var space_state = get_world_2d().direct_space_state
	
	for i in range(max_prediction):
		var target_pos = current_pos + current_velocity.normalized() * 2000.0
		
		var query = PhysicsRayQueryParameters2D.create(current_pos, target_pos)
		var result = space_state.intersect_ray(query)
		
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
	if not bullet_scene:
		return
		
	var bullet = bullet_scene.instantiate() as CharacterBody2D
	if not bullet:
		return
		
	bullet.global_position = muzzle.global_position
	
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - muzzle.global_position).normalized()
	bullet.velocity = direction * shoot_speed
	
	get_tree().current_scene.add_child(bullet)

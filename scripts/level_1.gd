extends Node2D

@onready var integral_zone: Area2D = $IntegralZone

var bullets_in_zone: Array[Node2D] = []

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	for bullet in bullets_in_zone:
		if is_instance_valid(bullet):
			if bullet.has_method("update_integral_effect"):
				pass

func _on_integral_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("bullet") and not bullets_in_zone.has(body):
		bullets_in_zone.append(body)
		print("Bullet in integral zone")
		
		if body.has_method("enter_integral_zone"):
			body.enter_integral_zone()
		
func _on_integral_zone_body_exited(body: Node2D) -> void:
	if body.is_in_group("bullet") and bullets_in_zone.has(body):
		bullets_in_zone.erase(body)
		print("Bullet leave integral zone")
		
		if body.has_method("exit_integral_zone"):
			body.exit_integral_zone()

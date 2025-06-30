extends RigidBody2D

@onready var sprite = $Sprite2D
@onready var body_collision_shape = $CollisionShape2D
@onready var area_collision_shape = $Area2D/CollisionShape2D

func _ready() -> void:
	await get_tree().process_frame
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = sprite.region_rect.size.x * 0.35
	body_collision_shape.shape = circle_shape
	area_collision_shape.shape = circle_shape

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("water"):
		gravity_scale = 0.1
		linear_damp = 20.0

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		queue_free()

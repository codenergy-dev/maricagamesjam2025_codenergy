extends Node

@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D.shape as CapsuleShape2D
@onready var audio = $AudioManager

func _physics_process(delta: float) -> void:
	collision_shape.radius = sprite.region_rect.size.x * 0.5
	collision_shape.height = sprite.region_rect.size.y - (collision_shape.radius * 2)

func _on_area_entered(area: Area2D) -> void:
	audio.play("hit")

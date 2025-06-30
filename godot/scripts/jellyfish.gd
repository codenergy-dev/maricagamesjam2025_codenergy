extends Node

@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D
@onready var audio = $AudioManager

func _ready() -> void:
	await get_tree().process_frame
	var capsule_shape = CapsuleShape2D.new()
	capsule_shape.radius = sprite.region_rect.size.x * 0.25
	capsule_shape.height = sprite.region_rect.size.y
	collision_shape.shape = capsule_shape

func _on_area_entered(area: Area2D) -> void:
	audio.play("hit")

extends Node

@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D
@onready var audio = $AudioManager
@onready var particles: CPUParticles2D = $CPUParticles2D

func _ready() -> void:
	await get_tree().process_frame
	
	var capsule_shape = CapsuleShape2D.new()
	capsule_shape.radius = sprite.region_rect.size.x * 0.25
	capsule_shape.height = sprite.region_rect.size.y
	collision_shape.shape = capsule_shape
	
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(sprite.region_rect.size.x * 0.25, sprite.region_rect.size.y * 0.5)

func _on_area_entered(area: Area2D) -> void:
	audio.play("hit")

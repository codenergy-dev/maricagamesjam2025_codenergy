extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var laser: Laser = $Laser

func _on_knockback_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		laser.queue_free()
		hitbox.queue_free()
		animated_sprite.play("knockback")
		await animated_sprite.animation_finished
		queue_free()

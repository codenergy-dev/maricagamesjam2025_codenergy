extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var laser: Laser = $Laser
@onready var visible_on_screen: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

func _on_knockback_area_entered(area: Area2D) -> void:
	if not visible_on_screen.is_on_screen():
		return
	if area.is_in_group("player"):
		laser.queue_free()
		hitbox.queue_free()
		animated_sprite.play("knockback")
		await animated_sprite.animation_finished
		queue_free()

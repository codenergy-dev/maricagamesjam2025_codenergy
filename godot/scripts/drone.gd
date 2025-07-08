extends CharacterBody2D

@export var move_speed = -100

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var visible_on_screen: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

func _physics_process(delta: float) -> void:
	if visible_on_screen.is_on_screen():
		velocity.x = move_speed
	move_and_slide()

func _on_knockback_area_entered(area: Area2D) -> void:
	if not visible_on_screen.is_on_screen():
		return
	if area.is_in_group("player"):
		hitbox.queue_free()
		animated_sprite.play("knockback")
		await animated_sprite.animation_finished
		queue_free()

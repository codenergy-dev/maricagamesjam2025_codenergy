extends CharacterBody2D

signal action_taken(action_details)

@onready var knockback = $Knockback
@onready var flash = $Flash

const SPEED = 300.0
const JUMP_VELOCITY = -500.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if knockback.is_zero() and Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		action_taken.emit({"type": "jump"})

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if knockback.is_zero() and direction:
		velocity.x = direction * SPEED
		action_taken.emit({"type": "move", "direction": direction})
	elif knockback.is_zero():
		if velocity.x != 0:
			action_taken.emit({"type": "move", "direction": 0})
		velocity.x = move_toward(velocity.x, 0, SPEED)

	velocity += knockback.knockback
	
	move_and_slide()
	
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# Se colidimos com algo do grupo "knockback"...
		if collider and collider.is_in_group("knockback"):
			# ...dizemos ao nosso componente para aplicar um novo knockback.
			# O Player não sabe COMO o knockback funciona, ele apenas o aciona.
			knockback.apply_knockback(collision.get_normal())
			flash.start_flash()

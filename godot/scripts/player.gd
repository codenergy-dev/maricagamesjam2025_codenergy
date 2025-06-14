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

func _on_knockback_body_entered(body: Node2D) -> void:
	if body.is_in_group("knockback"):
		# Não temos mais a "normal da colisão" de move_and_slide.
		# A melhor maneira de obter a direção do knockback é a partir da direção do projétil
		# ou da posição relativa entre o player e o projétil.

		# Opção Robusta: Calcular a normal baseada na posição
		var knockback_direction = (global_position - body.global_position).normalized()
		
		# Dizemos ao nosso componente para aplicar o knockback.
		knockback.apply_knockback(knockback_direction)
		flash.start_flash()

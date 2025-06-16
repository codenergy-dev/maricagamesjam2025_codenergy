extends CharacterBody2D

# A queue to store the player's actions
var action_queue = []
var is_following = false
var is_performing_action = false

# Movement properties should mirror the player's for an exact copy
@export var speed = 300.0
@export var jump_velocity = -500.0

# Delay in seconds before the cat mimics an action
@export var follow_delay = 0.01

# Get gravity from project settings
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D
@onready var timer = $Timer

func _ready():
	# Connect the area's signal to a function.
	$FollowArea.body_entered.connect(_on_follow_area_body_entered)
	# Connect the timer's timeout signal.
	timer.timeout.connect(_execute_next_action)
	# Set the timer to only run once per start() call.
	timer.one_shot = true
	timer.wait_time = follow_delay

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# If we are following and not busy, check for new actions to perform.
	if is_following and not action_queue.is_empty() and not is_performing_action:
		# Start the timer to introduce the delay.
		# The action will be executed when the timer finishes.
		is_performing_action = true
		timer.start()
		
	# Constant deceleration for the horizontal movement
	# This ensures the cat stops when the queued action is "stop".
	if velocity.x != 0 and get_action_type() != "move":
		velocity.x = move_toward(velocity.x, 0, speed)
	elif velocity == Vector2.ZERO and is_on_floor():
		animated_sprite.play("idle")

	move_and_slide()

# This function is called when the player enters the cat's detection area.
func _on_follow_area_body_entered(body):
	# Check if the body that entered is the player (e.g., by checking its script or group).
	# And ensure we only connect the signal once.
	if body.name == "Player" and not is_following:
		is_following = true
		# Connect to the player's action signal to start receiving its moves.
		body.action_taken.connect(_on_player_action_taken)

# This function is called every time the player emits the "action_taken" signal.
func _on_player_action_taken(action):
	# Add the received action to our queue.
	action_queue.append(action)

# This function is called when the ActionTimer times out.
func _execute_next_action():
	if action_queue.is_empty():
		is_performing_action = false
		return

	# Get the oldest action from the queue.
	var next_action = action_queue.pop_front()

	# Execute the action based on its type.
	if next_action.type == "jump":
		if is_on_floor():
			velocity.y = jump_velocity
			animated_sprite.play("jump")
	elif next_action.type == "move":
		var direction = next_action.direction
		if direction != 0:
			velocity.x = direction * speed
			animated_sprite.flip_h = direction > 0
			if is_on_floor():
				animated_sprite.play("walk")
		else:
			# This handles the "stop" action.
			velocity.x = 0
			
	# We are ready for the next action now.
	is_performing_action = false

# A helper function to check the type of the current action being performed.
func get_action_type():
	if not action_queue.is_empty() and is_performing_action:
		return action_queue[0].type
	return ""

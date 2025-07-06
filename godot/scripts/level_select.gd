extends CanvasLayer

@export var current_level: int = 0
@export var level_labels: Array[String] = []
@export var level_images: Array[Texture2D] = []

@onready var level_image: TextureRect = $"Control/Level/TextureRect"
@onready var level_label: Label = $"Control/Label"
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio: AudioManager = $AudioManager

func _ready() -> void:
	get_tree().root.add_to_group("game")

func _process(delta: float) -> void:
	level_image.texture = level_images[current_level]
	level_label.text = level_labels[current_level]
	
	if not animation_player.is_playing():
		if Input.is_action_just_pressed("ui_accept"):
			select()
		elif Input.is_action_just_pressed("ui_right"):
			_on_right_pressed()
		elif Input.is_action_just_pressed("ui_left"):
			_on_left_pressed()

func select():
	audio.play("select")
	await AudioFade.out(get_tree().root.get_node("AudioStreamPlayer"), 0.25)
	TransitionManager.transition("level_select_" + str(current_level))

func next():
	if current_level + 1 < level_images.size():
		current_level += 1
	else:
		current_level = 0

func previous():
	if current_level - 1 >= 0:
		current_level -= 1
	else:
		current_level = level_images.size() - 1

func _on_right_pressed() -> void:
	animation_player.play("swipe_left")
	audio.play("swipe")

func _on_left_pressed() -> void:
	animation_player.play("swipe_right")
	audio.play("swipe")

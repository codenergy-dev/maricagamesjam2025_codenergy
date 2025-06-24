class_name AudioManager
extends Node

var sounds: Dictionary[String, AudioStreamPlayer] = {}

func _ready() -> void:
	for child in get_children():
		if is_instance_of(child, AudioStreamPlayer):
			sounds[child.name.to_lower()] = child

func play(sound_name: String):
	if sounds.has(sound_name):
		sounds[sound_name].pitch_scale = randf_range(0.9, 1.1)
		sounds[sound_name].play()
	else:
		print("AVISO: Tentativa de tocar som desconhecido: ", sound_name)

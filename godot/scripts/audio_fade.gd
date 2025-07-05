class_name AudioFade

static func out(audio: AudioStreamPlayer, duration := 1.0) -> Signal:
	var tween = audio.create_tween()
	tween.tween_property(audio, "volume_db", -80, duration)
	return tween.finished

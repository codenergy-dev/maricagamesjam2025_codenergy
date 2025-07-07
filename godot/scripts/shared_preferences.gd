extends Node

const SAVE_PATH := "user://shared_preferences.json"

var _data: Dictionary = {}

func _ready():
	_load()

func _load():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		var parsed = JSON.parse_string(content)
		if parsed is Dictionary:
			_data = parsed

func _save():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(_data))
	file.close()

func set_value(key: String, value) -> void:
	_data[key] = value
	_save()

func get_value(key: String, default = null):
	return _data.get(key, default)

func set_string(key: String, value: String) -> void:
	set_value(key, value)

func set_int(key: String, value: int) -> void:
	set_value(key, value)

func set_float(key: String, value: float) -> void:
	set_value(key, value)

func set_bool(key: String, value: bool) -> void:
	set_value(key, value)

func set_string_list(key: String, value: Array) -> void:
	set_value(key, value)

func set_int_list(key: String, value: Array) -> void:
	set_value(key, value)

func get_string(key: String, default: String = "") -> String:
	return str(get_value(key, default))

func get_int(key: String, default: int = 0) -> int:
	return int(get_value(key, default))

func get_float(key: String, default: float = 0.0) -> float:
	return float(get_value(key, default))

func get_bool(key: String, default: bool = false) -> bool:
	return bool(get_value(key, default))

func get_string_list(key: String, default: Array = []) -> Array:
	return Array(get_value(key, default))

func get_int_list(key: String, default: Array = []) -> Array:
	return Array(get_value(key, default))

func remove(key: String) -> void:
	if _data.has(key):
		_data.erase(key)
		_save()

func clear() -> void:
	_data.clear()
	_save()

extends BaseButton

@export var action: String = "ui_accept"

# Conectado ao sinal "button_down"
func _on_button_down():
	# Cria um evento de ação artificial
	var event = InputEventAction.new()
	event.action = action
	event.pressed = true
	# Envia o evento para o sistema de input do Godot, que o processará como um input real.
	Input.parse_input_event(event)

# Conectado ao sinal "button_up"
func _on_button_up():
	var event = InputEventAction.new()
	event.action = action
	event.pressed = false # Agora é um evento de "soltar"
	Input.parse_input_event(event)

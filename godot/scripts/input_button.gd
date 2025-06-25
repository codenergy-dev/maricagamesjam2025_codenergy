extends TextureButton

@export var action: String = "ui_accept"

# Esta função é chamada automaticamente sempre que um toque ou clique
# acontece na área deste botão.
func _gui_input(event: InputEvent):
	# Primeiro, verificamos se o evento é de fato um toque na tela.
	if event is InputEventScreenTouch:
		# A propriedade 'pressed' do evento nos diz se o dedo acabou de tocar
		# na tela (true) ou se acabou de ser retirado (false).
		if event.pressed:
			# Simula o pressionar da ação "ui_accept"
			var press_event = InputEventAction.new()
			press_event.action = action
			press_event.pressed = true
			Input.parse_input_event(press_event)
		else:
			# Simula o soltar da ação "ui_accept"
			var release_event = InputEventAction.new()
			release_event.action = action
			release_event.pressed = false # `pressed = false` é como um evento de "soltar"
			Input.parse_input_event(release_event)

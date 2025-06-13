# flash_component.gd
extends Node

## O nó visual que queremos que pisque (ex: Sprite2D, AnimatedSprite2D).
@export var target_node: Node2D
## A cor que será usada para o "pisca". O branco total é ótimo para um flash brilhante.
@export var flash_color: Color = Color.WHITE
## Por quanto tempo o efeito de piscar deve durar, em segundos.
@export var flash_duration: float = 0.5
## Quantas vezes o sprite deve piscar por segundo.
@export var flash_frequency: float = 10.0

# Timer interno para controlar a duração do efeito
var _flash_timer: Timer
# Guarda a cor original do alvo para podermos restaurá-la depois.
var _original_color: Color

func _ready():
	# Verificação para garantir que o nó alvo foi definido no editor
	if not target_node:
		print_rich("[color=red]AVISO:[/color] 'target_node' não foi definido no FlashComponent. O efeito não funcionará.")
		# Desativa o processamento para economizar recursos se não houver alvo.
		set_process(false)
		return
	
	# Guardamos a cor original do modulate do nosso alvo.
	_original_color = target_node.modulate

	# Criamos um Timer via código. Ele será usado para parar o efeito.
	_flash_timer = Timer.new()
	add_child(_flash_timer) # Adicionamos o timer como filho deste nó
	_flash_timer.one_shot = true # Queremos que ele dispare apenas uma vez
	_flash_timer.timeout.connect(_on_flash_timer_timeout) # Conectamos seu sinal


func _process(delta: float):
	# Se o timer não estiver rodando, não há nada a fazer.
	if _flash_timer.is_stopped():
		return

	# Esta é a matemática que cria o efeito de piscar.
	# Usamos uma onda senoidal baseada no tempo para alternar a cor.
	var time = _flash_timer.wait_time - _flash_timer.time_left
	var intensity = sin(time * flash_frequency * 2 * PI)
	
	if intensity > 0:
		target_node.modulate = flash_color
	else:
		target_node.modulate = _original_color


## Função pública que o Player (ou qualquer outro nó) irá chamar
func start_flash():
	# Se o alvo não foi definido, não fazemos nada.
	if not target_node:
		return
	
	# Inicia o timer com a duração que definimos.
	_flash_timer.start(flash_duration)
	# Ativa a função _process para que o pisca-pisca comece.
	set_process(true)


## Esta função é chamada automaticamente quando o Timer chega a zero.
func _on_flash_timer_timeout():
	# Para garantir, restauramos a cor original do alvo.
	target_node.modulate = _original_color
	# Desativamos o processamento para não gastar recursos à toa.
	set_process(false)

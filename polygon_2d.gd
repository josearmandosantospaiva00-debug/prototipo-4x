extends Polygon2D

var raio_hexagono = 60.0 # O tamanho do nosso hexágono

func _ready():
	# _ready() é uma função nativa que roda uma única vez quando o jogo começa.
	# Vamos centralizar o objeto na tela (a tela padrão tem 1152x648)
	position = Vector2(1152 / 2, 648 / 2)
	
	# Chama a nossa função matemática
	gerar_hexagono()

func gerar_hexagono():
	var pontos = PackedVector2Array() # Cria um array (uma lista) de vetores vazia
	
	# Um círculo tem 360 graus. Dividido por 6 pontas = 60 graus por ponta.
	for i in range(6):
		# A Godot, assim como o Python, calcula seno e cosseno em radianos
		var angulo_radianos = deg_to_rad(60 * i)
		
		# Calculando as coordenadas X e Y do vetor
		var x = raio_hexagono * cos(angulo_radianos)
		var y = raio_hexagono * sin(angulo_radianos)
		
		# Adiciona o novo vetor à nossa lista de pontos
		pontos.append(Vector2(x, y))
		
	# Atribui a lista matemática perfeita ao desenho do polígono
	polygon = pontos

func _input(event):
	# O código do clique continua exatamente igual!
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var clique_local = get_local_mouse_position()
		if Geometry2D.is_point_in_polygon(clique_local, polygon):
			color = Color(randf(), randf(), randf())

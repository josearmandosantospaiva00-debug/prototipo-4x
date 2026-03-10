extends Node2D
var cristais_coletados = 0
@onready var label_cristais = $CanvasLayer/LabelCristais # Verifique se o nome está igual ao do nó
var raio = 40.0
var colunas = 30
var linhas = 20
var lista_hexagonos = [] 

var unidade: Sprite2D
var pontos_movimento_maximos = 3 
var pontos_movimento_atuais = 3

var camera: Camera2D
var velocidade_camera = 600.0

# --- NOVA VARIÁVEL: REFERÊNCIA PARA O TEXTO ---
# Usamos @onready para o script esperar a interface carregar antes de tentar usá-la
@onready var label_movimento = $CanvasLayer/Label

func _ready():
	camera = Camera2D.new()
	camera.position = Vector2(1152 / 2, 648 / 2)
	add_child(camera)
	
	for col in range(colunas):
		for row in range(linhas):
			criar_hexagono(col, row)
			
	unidade = Sprite2D.new()
	unidade.texture = preload("res://icon.svg")
	unidade.scale = Vector2(0.4, 0.4)
	unidade.position = lista_hexagonos[0].position 
	add_child(unidade)
	
	# Atualiza a interface pela primeira vez
	atualizar_ui()

# --- FUNÇÃO PARA ATUALIZAR O TEXTO NA TELA ---
func atualizar_ui():
	label_movimento.text = "Pontos de Movimento: " + str(pontos_movimento_atuais) + " / " + str(pontos_movimento_maximos)
	# Se os pontos acabarem, vamos pintar o texto de vermelho para avisar o jogador
	if pontos_movimento_atuais == 0:
		label_movimento.add_theme_color_override("font_color", Color.RED)
	else:
		label_movimento.add_theme_color_override("font_color", Color.WHITE)

func criar_hexagono(col, row):
	var poly = Polygon2D.new()
	var x = col * (1.5 * raio)
	var y = row * (sqrt(3) * raio)
	if col % 2 != 0: y += (sqrt(3) / 2.0) * raio
	x += 100
	y += 100
	poly.position = Vector2(x, y)
	poly.set_script(load("res://polygon_2d.gd"))
	poly.polygon = gerar_pontos()
	
	var chance = randf()
	var custo = 1
	var cor_escolhida
	if chance < 0.30:
		cor_escolhida = Color(0.1, 0.4, 0.1) # Floresta
		custo = 2
	else:
		cor_escolhida = Color(0.4, 0.7, 0.4) # Planície
	
	# Em vez de mudar a cor direto, chamamos a função que esconde
	poly.configurar_cores(cor_escolhida)
	# Chance de ter um cristal (15%)
	if randf() < 0.15:
		poly.set_meta("tem_cristal", true)
		# Vamos colocar um pontinho visual para sabermos que tem cristal
		var cristal_visual = ColorRect.new()
		cristal_visual.size = Vector2(10, 10)
		cristal_visual.position = Vector2(-5, -5) # Centraliza no hexágono
		cristal_visual.color = Color.CYAN # Azul brilhante
		poly.add_child(cristal_visual)
	else:
		poly.set_meta("tem_cristal", false)
	poly.set_meta("custo", custo)
	add_child(poly)
	lista_hexagonos.append(poly)

func gerar_pontos():
	var pontos = PackedVector2Array()
	for i in range(6):
		var angulo = deg_to_rad(60 * i)
		pontos.append(Vector2(raio * cos(angulo), raio * sin(angulo)))
	return pontos

func _process(delta):
	var direcao = Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): direcao.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): direcao.y += 1
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): direcao.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): direcao.x += 1
	if direcao != Vector2.ZERO:
		camera.position += direcao.normalized() * velocidade_camera * delta

func _input(event):
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		pontos_movimento_atuais = pontos_movimento_maximos
		atualizar_ui()

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var clique = get_global_mouse_position()
		var hex_clicado = null
		var menor_distancia = INF
		
		for hex in lista_hexagonos:
			var d = clique.distance_to(hex.position)
			if d < menor_distancia:
				menor_distancia = d
				hex_clicado = hex
				
		if menor_distancia <= raio:
			var dist_mov = unidade.position.distance_to(hex_clicado.position)
			var limite = (sqrt(3) * raio) + 1.0 
			
			if dist_mov > 1.0 and dist_mov <= limite:
				var custo_entrar = hex_clicado.get_meta("custo")
				if pontos_movimento_atuais >= custo_entrar:
					pontos_movimento_atuais -= custo_entrar
					
					var tween = create_tween()
					tween.tween_property(unidade, "position", hex_clicado.position, 0.3)
					tween.finished.connect(apos_movimento)
					tween.set_trans(Tween.TRANS_SINE)
					tween.set_ease(Tween.EASE_OUT)
					# ATUALIZA A UI APÓS MOVER
					atualizar_ui()
					


func _on_button_pressed() -> void:
	pontos_movimento_atuais = pontos_movimento_maximos
	atualizar_ui()
	print("Botão clicado! Turno resetado.")
func atualizar_visao():
	var raio_visao = raio * 3.5 # Define o quão longe o robô enxerga
	
	for hex in lista_hexagonos:
		var distancia = unidade.position.distance_to(hex.position)
		if distancia <= raio_visao:
			hex.revelar()
func checar_coleta():
	for hex in lista_hexagonos:
		# Se o robô está na mesma posição do hexágono e tem cristal
		if unidade.position == hex.position and hex.get_meta("tem_cristal"):
			cristais_coletados += 1
			hex.set_meta("tem_cristal", false) # Remove o cristal do dado
			
			# Remove o visual do cristal (o primeiro filho do hexágono)
			for child in hex.get_children():
				if child is ColorRect:
					child.queue_free()
			
			atualizar_ui_cristais()
			print("Cristal coletado! Total: ", cristais_coletados)

func atualizar_ui_cristais():
	label_cristais.text = "Cristais: " + str(cristais_coletados)
func apos_movimento():
	atualizar_visao()
	checar_coleta()

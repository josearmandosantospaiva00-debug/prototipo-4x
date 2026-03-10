extends Polygon2D

var cor_real: Color
var descoberto = false

func _ready():
	# Deixamos o ready vazio ou apenas com o estado inicial
	pass

# Criamos esta função para o mapa chamar
func configurar_cores(cor_vinda_do_mapa: Color):
	cor_real = cor_vinda_do_mapa
	# Começa escondido (Azul escuro/preto)
	color = Color(0.05, 0.05, 0.1) 

func revelar():
	if not descoberto:
		descoberto = true
		var tween = create_tween()
		tween.tween_property(self, "color", cor_real, 0.5)

extends Node

signal sin_vidas

var vidas_totales = 5
var vidas_actuales = 5

@onready var contenedor_corazones = $ContenedorCorazones
@onready var gestor_juego = %GameManager

func _ready():
	actualizar_interfaz()

func perder_vida():
	vidas_actuales -= 1
	actualizar_interfaz()
	
	if vidas_actuales <= 0:
		emit_signal("sin_vidas")

func actualizar_interfaz():
	for i in range(contenedor_corazones.get_child_count()):
		if i < vidas_actuales:
			contenedor_corazones.get_child(i).visible = true
		else:
			contenedor_corazones.get_child(i).visible = false

func reiniciar_vidas():
	vidas_actuales = vidas_totales
	actualizar_interfaz()
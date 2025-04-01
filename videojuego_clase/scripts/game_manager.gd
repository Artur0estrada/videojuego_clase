extends Node

var puntuacion = 0

@onready var etiqueta_puntuacion = $ScoreLabel

func añadir_punto():
	puntuacion += 1
	etiqueta_puntuacion.text = "Has recogido " + str(puntuacion) + " monedas."
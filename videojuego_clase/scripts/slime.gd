extends Node2D

const VELOCIDAD = 60

var direccion = 1

@onready var rayo_derecha = $RayCastRight
@onready var rayo_izquierda = $RayCastLeft
@onready var sprite_animado = $AnimatedSprite2D

func _process(delta):
	if rayo_derecha.is_colliding():
		direccion = -1
		sprite_animado.flip_h = true
	if rayo_izquierda.is_colliding():
		direccion = 1
		sprite_animado.flip_h = false
	
	position.x += direccion * VELOCIDAD * delta
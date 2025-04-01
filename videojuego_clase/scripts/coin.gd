extends Area2D

@onready var gestor_juego = %GameManager
@onready var animacion = $AnimationPlayer

func _on_body_entered(body):
	gestor_juego.añadir_punto()
	animacion.play("pickup")
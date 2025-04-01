extends Area2D

@onready var temporizador = $Timer
@onready var sistema_vidas = %SistemaVidas

func _ready():
	sistema_vidas.connect("sin_vidas", _on_sin_vidas)

func _on_body_entered(body):
	print("¡Has perdido una vida!")
	Engine.time_scale = 0.5
	body.get_node("CollisionShape2D").set_deferred("disabled", true)
	sistema_vidas.perder_vida()
	temporizador.start()

func _on_timer_timeout():
	Engine.time_scale = 1.0
	var jugador = get_tree().get_nodes_in_group("jugador")[0]
	jugador.global_position = jugador.posicion_inicial
	jugador.get_node("CollisionShape2D").set_deferred("disabled", false)
	
func _on_sin_vidas():
	print("¡Game Over!")
	await get_tree().create_timer(1.0).timeout
	sistema_vidas.reiniciar_vidas()
	get_tree().reload_current_scene()
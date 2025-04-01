extends CharacterBody2D

const VELOCIDAD = 130.0
const VELOCIDAD_SALTO = -300.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravedad = ProjectSettings.get_setting("physics/2d/default_gravity")
var posicion_inicial = Vector2.ZERO

@onready var sprite_animado = $AnimatedSprite2D

func _ready():
	posicion_inicial = global_position
	add_to_group("jugador")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravedad * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = VELOCIDAD_SALTO

	var direccion = Input.get_axis("move_left", "move_right")
	
	if direccion > 0:
		sprite_animado.flip_h = false
	elif direccion < 0:
		sprite_animado.flip_h = true
	
	if is_on_floor():
		if direccion == 0:
			sprite_animado.play("idle")
		else:
			sprite_animado.play("run")
	else:
		sprite_animado.play("jump")
	
	if direccion:
		velocity.x = direccion * VELOCIDAD
	else:
		velocity.x = move_toward(velocity.x, 0, VELOCIDAD)

	move_and_slide()
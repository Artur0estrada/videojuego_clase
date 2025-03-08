extends CharacterBody2D

var speed = 200
var animation_player

func _ready():
    animation_player = $AnimationPlayer  

func _physics_process(delta):
    var velocity = Vector2.ZERO
    
    if Input.is_action_pressed("ui_right"):
        velocity.x += 1
    if Input.is_action_pressed("ui_left"):
        velocity.x -= 1
    if Input.is_action_pressed("ui_down"):
        velocity.y += 1
    if Input.is_action_pressed("ui_up"):
        velocity.y -= 1
    
    if velocity.length() > 0:
        velocity = velocity.normalized() * speed
        
        if abs(velocity.x) > abs(velocity.y):
            if velocity.x > 0:
                animation_player.play("walk_right")
            else:
                animation_player.play("walk_left")
        else:
            if velocity.y > 0:
                animation_player.play("walk_down")
            else:
                animation_player.play("walk_up")
    else:
        animation_player.play("idle")
    
    set_velocity(velocity)
    move_and_slide()

func _ready():
    $Camera2D.current = true  
    
extends Camera2D

var target_node

func _ready():
    target_node = get_node("../Player")  
    current = true

func _process(delta):
    if target_node:
        global_position = target_node.global_position

extends Node

func _ready():
    $BackgroundMusic.play()
    
func play_effect(effect_name):
    match effect_name:
        
extends CharacterBody2D

var speed = 100
var player
var detect_radius = 200
var attack_radius = 50

func _ready():
    player = get_node("../Player")  

func _physics_process(delta):
    if player:
        var distance = global_position.distance_to(player.global_position)
        
        if distance < detect_radius and distance > attack_radius:
            var direction = (player.global_position - global_position).normalized()
            velocity = direction * speed
            
            $AnimationPlayer.play("walk")
        elif distance <= attack_radius:
            velocity = Vector2.ZERO
            $AnimationPlayer.play("attack")
        else:
            velocity = Vector2.ZERO
            $AnimationPlayer.play("idle")
            
        move_and_slide()
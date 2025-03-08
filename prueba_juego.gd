extends CharacterBody2D

var speed = 200
var animation_player

func _ready():
    animation_player = $AnimationPlayer
    $Camera2D.current = true  

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

# Camara
extends Camera2D

var target_node

func _ready():
    target_node = get_node("../Player")  
    current = true

func _process(delta):
    if target_node:
        global_position = target_node.global_position

extends Node

var sound_effects = {
    #
}

func _ready():
    var tilemap = $TileMap
    if tilemap:
        print("TileMap initialized")
    
    $BackgroundMusic.stream = preload("res://resources/BackgroundMusic.mp3")
    $BackgroundMusic.play()
    
func play_effect(effect_name):
    if sound_effects.has(effect_name):
        var audio_player = AudioStreamPlayer.new()
        add_child(audio_player)
        audio_player.stream = sound_effects[effect_name]
        audio_player.play()
        yield(audio_player, "finished")
        audio_player.queue_free()

extends CharacterBody2D

var speed = 100
var player
var detect_radius = 200
var attack_radius = 50
var enemy_type = "default"  

func _ready():
    player = get_node("../Player")
    
    match enemy_type:
        "slime":
            $Sprite2D.texture = preload("res://resources/enemies/slime.png")
        "skeleton":
            $Sprite2D.texture = preload("res://resources/enemies/skeleton.png")
        "ghost":
            $Sprite2D.texture = preload("res://resources/enemies/ghost.png")
        _:
            print("Unknown enemy type: ", enemy_type)

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
            var game_manager = get_node("/root/GameManager")
            if game_manager:
                game_manager.play_effect("attack")
        else:
            velocity = Vector2.ZERO
            $AnimationPlayer.play("idle")
            
        move_and_slide()

extends TileMap

func _ready():
    var tileset = TileSet.new()
    var tile_texture = preload("res://resources/FieldsTile_n.png")
    

    for x in range(4): 
        for y in range(4):
            var region = Rect2(x * 64, y * 64, 64, 64) 
            tileset.create_tile(x + y * 4)
            tileset.tile_set_texture(x + y * 4, tile_texture)
            tileset.tile_set_region(x + y * 4, region)
    
    set_tileset(tileset)


extends Node

var player_lives = 5
var player_score = 0
var game_started = false

func _ready():
    $UI/MainMenu.visible = true
    $UI/GameUI.visible = false
    $UI/CreditsScreen.visible = false
    $BackgroundMusic.stream = preload("res://resources/BackgroundMusic.mp3")
    $BackgroundMusic.play()

func start_game():
    game_started = true
    player_lives = 5
    player_score = 0
    $UI/MainMenu.visible = false
    $UI/GameUI.visible = true
    $UI/CreditsScreen.visible = false
    $Player.position = $PlayerStartPosition.position
    $Player.can_move = true
    update_ui()
    
    
    for enemy in get_tree().get_nodes_in_group("enemies"):
        enemy.reset()

func game_over():
    game_started = false
    $UI/MainMenu.visible = true
    $UI/GameUI.visible = false
    $UI/CreditsScreen.visible = false
    $UI/MainMenu/GameOverLabel.visible = true
    $Player.can_move = false

func show_credits():
    $UI/MainMenu.visible = false
    $UI/GameUI.visible = false
    $UI/CreditsScreen.visible = true

func back_to_main_menu():
    $UI/MainMenu.visible = true
    $UI/GameUI.visible = false
    $UI/CreditsScreen.visible = false
    $UI/MainMenu/GameOverLabel.visible = false

func add_score(points):
    player_score += points
    update_ui()

func take_damage():
    player_lives -= 1
    update_ui()
    
    if player_lives <= 0:
        game_over()
    else:
        $Player.hit()

func update_ui():
    $UI/GameUI/ScoreLabel.text = "Score: " + str(player_score)
    
    # Vidas
    for i in range(5):
        var heart = $UI/GameUI/HeartsContainer.get_child(i)
        heart.visible = i < player_lives

func play_effect(effect_name):
    var sound_effects = {
        "hit": preload("res://path_to_hit_sound.wav"),
        "coin": preload("res://path_to_coin_sound.wav"),
        "game_over": preload("res://path_to_game_over_sound.wav")
    }
    
    if sound_effects.has(effect_name):
        var audio_player = AudioStreamPlayer.new()
        add_child(audio_player)
        audio_player.stream = sound_effects[effect_name]
        audio_player.play()
        await audio_player.finished
        audio_player.queue_free()

func exit_game():
    get_tree().quit()

# Player Script
extends CharacterBody2D

var speed = 200
var animation_player
var can_move = true
var invulnerable = false
var invulnerable_time = 2.0

func _ready():
    animation_player = $AnimationPlayer
    $Camera2D.current = true
    add_to_group("player")

func _physics_process(delta):
    if !can_move:
        return
        
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
    
    # Colision
    for i in get_slide_collision_count():
        var collision = get_slide_collision(i)
        if collision.get_collider().is_in_group("enemies") and !invulnerable:
            get_node("/root/GameManager").take_damage()

func hit():
    invulnerable = true
    animation_player.play("hit")
    
    var tween = create_tween()
    for i in range(5):
        tween.tween_property(self, "modulate:a", 0.2, 0.2)
        tween.tween_property(self, "modulate:a", 1.0, 0.2)
    
    await get_tree().create_timer(invulnerable_time).timeout
    invulnerable = false
    modulate.a = 1.0

# Enemy Script
extends CharacterBody2D

var speed = 100
var player
var detect_radius = 200
var attack_radius = 50
var enemy_type = "default"
var damage_cooldown = 1.0
var can_damage = true
var initial_position = Vector2()
var damage = 1
var points_value = 10
var is_dead = false

func _ready():
    initial_position = position
    player = get_tree().get_first_node_in_group("player")
    add_to_group("enemies")
    
    match enemy_type:
        "slime":
            $Sprite2D.texture = preload("res://resources/enemies/slime.png")
        "skeleton":
            $Sprite2D.texture = preload("res://resources/enemies/skeleton.png")
        "ghost":
            $Sprite2D.texture = preload("res://resources/enemies/ghost.png")
        _:
            print("Unknown enemy type: ", enemy_type)

func _physics_process(delta):
    if is_dead or !player:
        return
        
    var distance = global_position.distance_to(player.global_position)
    
    if distance < detect_radius and distance > attack_radius:
        var direction = (player.global_position - global_position).normalized()
        velocity = direction * speed
        
        $AnimationPlayer.play("walk")
    elif distance <= attack_radius:
        velocity = Vector2.ZERO
        $AnimationPlayer.play("attack")
        
        if can_damage:
            attack_player()
    else:
        velocity = Vector2.ZERO
        $AnimationPlayer.play("idle")
        
    move_and_slide()

func attack_player():
    can_damage = false
    
    # Colision
    var bodies = $HitArea.get_overlapping_bodies()
    for body in bodies:
        if body.is_in_group("player") and !body.invulnerable:
            get_node("/root/GameManager").take_damage()
    
    await get_tree().create_timer(damage_cooldown).timeout
    can_damage = true

func take_damage(amount):
    $AnimationPlayer.play("hurt")
    
    is_dead = true
    $CollisionShape2D.disabled = true
    
    get_node("/root/GameManager").add_score(points_value)
    
    var tween = create_tween()
    tween.tween_property(self, "modulate:a", 0, 0.5)
    await tween.finished
    
    queue_free()

func reset():
    position = initial_position
    is_dead = false
    if $CollisionShape2D:
        $CollisionShape2D.disabled = false
    modulate.a = 1.0

# Main Menu
extends Control

func _ready():
    $GameOverLabel.visible = false
    $TitleLabel.text = "My Awesome Game"
    
func _on_play_button_pressed():
    get_node("/root/GameManager").start_game()
    
func _on_credits_button_pressed():
    get_node("/root/GameManager").show_credits()
    
func _on_exit_button_pressed():
    get_node("/root/GameManager").exit_game()

# Creditos
extends Control

func _ready():
    $CreditsLabel.text = """
    Game Development: [Your Name]
    Art Assets: [Source]
    Music: [Source]
    Special Thanks: [Anyone else]
    
    Made with Godot Engine
    """
    
func _on_back_button_pressed():
    get_node("/root/GameManager").back_to_main_menu()

# UI
extends Control

func _ready():
    $HeartsContainer.horizontal = true
    for i in range(5):
        var heart = TextureRect.new()
        heart.texture = preload("res://path_to_heart_texture.png")
        heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        heart.custom_minimum_size = Vector2(32, 32)
        $HeartsContainer.add_child(heart)

extends Area2D

var points = 5
var collected = false

func _ready():
    add_to_group("collectibles")

func _on_body_entered(body):
    if body.is_in_group("player") and !collected:
        collected = true
        get_node("/root/GameManager").add_score(points)
        get_node("/root/GameManager").play_effect("coin")
        
        var tween = create_tween()
        tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.2)
        tween.tween_property(self, "scale", Vector2(0, 0), 0.2)
        await tween.finished
        
        queue_free()
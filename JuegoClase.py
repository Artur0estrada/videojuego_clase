import pygame
import random

pygame.init()
pygame.mixer.init()
pygame.mixer.music.load('assets/BackgroundMusic.mp3')  
pygame.mixer.music.play(-1) 

WIDTH, HEIGHT = 1024, 768
PLAYER_SPEED = 4
ENEMY_SPEED = 2
LIVES = 3
TILE_SIZE = 40

screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("Juego en Pygame")

player_img = pygame.image.load('assets/player.png')
enemy_img = pygame.image.load('assets/enemy.png')
heart_img = pygame.image.load('assets/heart.png')
grass_img = pygame.image.load('assets/grass.png')
wall_img = pygame.image.load('assets/wall.png')

player_img = pygame.transform.scale(player_img, (TILE_SIZE, TILE_SIZE))
enemy_img = pygame.transform.scale(enemy_img, (TILE_SIZE, TILE_SIZE))
heart_img = pygame.transform.scale(heart_img, (20, 20))
grass_img = pygame.transform.scale(grass_img, (TILE_SIZE, TILE_SIZE))
wall_img = pygame.transform.scale(wall_img, (TILE_SIZE, TILE_SIZE))

player = pygame.Rect(WIDTH // 2, HEIGHT // 2, TILE_SIZE, TILE_SIZE)

enemies = [pygame.Rect(random.randint(0, WIDTH - TILE_SIZE), random.randint(0, HEIGHT - TILE_SIZE), TILE_SIZE, TILE_SIZE) for _ in range(2)]

score = 0
hearts = LIVES

map_width = WIDTH // TILE_SIZE
map_height = HEIGHT // TILE_SIZE

tilemap = []
for _ in range(map_height):
    row = ['grass'] * map_width
    tilemap.append(row)

for y in range(3, map_height - 3):
    tilemap[y][5] = 'wall'
    tilemap[y][1] = 'wall'
    
for x in range(3, map_width - 3):
    tilemap[3][x] = 'wall'
    tilemap[map_height - 4][x] = 'wall'
    
for _ in range(1):
    x = random.randint(2, map_width - 3)
    y = random.randint(2, map_height - 3)
    tilemap[y][x] = 'wall'

def draw_tilemap():
    for row in range(len(tilemap)):
        for col in range(len(tilemap[row])):
            tile_type = tilemap[row][col]
            tile_rect = pygame.Rect(col * TILE_SIZE, row * TILE_SIZE, TILE_SIZE, TILE_SIZE)
            
            if tile_type == 'grass':
                screen.blit(grass_img, tile_rect)
            elif tile_type == 'wall':
                screen.blit(wall_img, tile_rect)

def move_enemy(enemy):
    directions = [(ENEMY_SPEED, 0), (-ENEMY_SPEED, 0), (0, ENEMY_SPEED), (0, -ENEMY_SPEED)]
    dx, dy = random.choice(directions)
    
    new_x = enemy.x + dx
    new_y = enemy.y + dy
    
    if 0 <= new_x < WIDTH - TILE_SIZE and 0 <= new_y < HEIGHT - TILE_SIZE:
        tile_x = new_x // TILE_SIZE
        tile_y = new_y // TILE_SIZE
        
        if 0 <= tile_x < len(tilemap[0]) and 0 <= tile_y < len(tilemap):
            if tilemap[tile_y][tile_x] != 'wall':
                enemy.x = new_x
                enemy.y = new_y

def check_collision():
    global hearts, score
    for enemy in enemies[:]:
        if player.colliderect(enemy):
            hearts -= 1
            score += 10  
            print(f"COLISION! vidas restantes: {hearts}, Score: {score}")
            if hearts <= 0:
                print("Game Over!")
                show_game_over()
                return
            
            enemy.x = random.randint(0, WIDTH - TILE_SIZE)
            enemy.y = random.randint(0, HEIGHT - TILE_SIZE)
            enemies.remove(enemy)

def can_move_to(x, y):
    if x < 0 or x + TILE_SIZE > WIDTH or y < 0 or y + TILE_SIZE > HEIGHT:
        return False
        
    tile_x = x // TILE_SIZE
    tile_y = y // TILE_SIZE
    
    if 0 <= tile_x < len(tilemap[0]) and 0 <= tile_y < len(tilemap):
        if tilemap[tile_y][tile_x] == 'wall':
            return False
        return True
    return False

def show_game_over():
    font = pygame.font.Font(None, 74)
    text = font.render("GAME OVER", True, (255, 0, 0))
    screen.blit(text, (WIDTH // 2 - text.get_width() // 2, HEIGHT // 2 - 100))
    
    font = pygame.font.Font(None, 36)
    text = font.render(f"Score: {score}", True, (255, 255, 255))
    screen.blit(text, (WIDTH // 2 - text.get_width() // 2, HEIGHT // 2))
    
    pygame.display.update()
    pygame.time.wait(3000)
    pygame.quit()
    exit()

def show_credits():
    font = pygame.font.Font(None, 74)
    text = font.render("CREDITOS", True, (255, 255, 0))
    screen.blit(text, (WIDTH // 2 - text.get_width() // 2, HEIGHT // 2 - 100))
    
    font = pygame.font.Font(None, 36)
    text = font.render("Desarrollado by Luis Arturo", True, (255, 255, 255))
    screen.blit(text, (WIDTH // 2 - text.get_width() // 2, HEIGHT // 2))
    
    text = font.render("Para la materia de videojuegos", True, (255, 255, 255))
    screen.blit(text, (WIDTH // 2 - text.get_width() // 2, HEIGHT // 2 + 50))
    
    pygame.display.update()
    pygame.time.wait(5000)
    pygame.quit()
    exit()

running = True
while running:
    pygame.time.delay(30)
    screen.fill((255, 255, 255)) 

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
    
    draw_tilemap()

    keys = pygame.key.get_pressed()

    if keys[pygame.K_LEFT] and can_move_to(player.x - PLAYER_SPEED, player.y):
        player.x -= PLAYER_SPEED
    if keys[pygame.K_RIGHT] and can_move_to(player.x + PLAYER_SPEED, player.y):
        player.x += PLAYER_SPEED
    if keys[pygame.K_UP] and can_move_to(player.x, player.y - PLAYER_SPEED):
        player.y -= PLAYER_SPEED
    if keys[pygame.K_DOWN] and can_move_to(player.x, player.y + PLAYER_SPEED):
        player.y += PLAYER_SPEED

    player.clamp_ip(screen.get_rect())

    for enemy in enemies:
        move_enemy(enemy)

    check_collision()

    screen.blit(player_img, player)
    for enemy in enemies:
        screen.blit(enemy_img, enemy)

    for i in range(hearts):
        screen.blit(heart_img, (10 + i * 30, 10))

    font = pygame.font.Font(None, 36)
    text = font.render(f"Score: {score}", True, (0, 0, 0))
    screen.blit(text, (WIDTH - 150, 10))

    if len(enemies) == 0:
        show_credits()

    pygame.display.update()

pygame.quit()

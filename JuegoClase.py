import pygame
import random

pygame.init()

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

hearts = LIVES

tilemap = [
    ['grass', 'grass', 'grass', 'grass', 'wall', 'wall', 'grass', 'grass'],
    ['grass', 'wall', 'wall', 'grass', 'wall', 'wall', 'grass', 'grass'],
    ['grass', 'grass', 'grass', 'grass', 'wall', 'grass', 'grass', 'grass'],
    ['grass', 'wall', 'wall', 'grass', 'wall', 'wall', 'wall', 'grass'],
    ['grass', 'grass', 'grass', 'grass', 'wall', 'grass', 'grass', 'grass'],
]

def draw_tilemap():
    """Draw the tilemap using the tile images."""
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
    enemy.x += dx
    enemy.y += dy
    enemy.clamp_ip(screen.get_rect())  

def check_collision():
    global hearts
    for enemy in enemies:
        if player.colliderect(enemy):
            hearts -= 1
            print(f"Collision detected! Lives left: {hearts}")
            if hearts <= 0:
                print("Game Over!")
                pygame.quit()
                exit()

def can_move_to(x, y):
    tile_x = x // TILE_SIZE
    tile_y = y // TILE_SIZE

    if tilemap[tile_y][tile_x] == 'wall':
        return False  
    return True

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

    pygame.display.update()

pygame.quit()

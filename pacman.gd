extends CharacterBody2D

var speed = 60  # Velocidad de Pac-Man
var direction = Vector2()  # Dirección actual de Pac-Man
var target_position = Vector2()
var target_position_izq = Vector2()
var target_position_der = Vector2()
var next_tile_position = Vector2()
var moving = false
var death = false
var dying = false
var eating_ghosts = false
var elapsed_time_dots = 0 
var timer_duration_dots = 0.2 

@onready var anim_sprite = $Sprite2D/AnimationPlayer
@onready var tile_map = get_node("/root/Juego/TileMap")
@onready var tile_size = Vector2(tile_map.tile_set.tile_size)
@onready var siren_1Sound = get_node("/root/Juego/Siren_1Sound") 
@onready var munch_1Sound = get_node("/root/Juego/Munch_1Sound") 
@onready var munch_2Sound = get_node("/root/Juego/Munch_2Sound") 
@onready var death_1Sound = get_node("/root/Juego/Death_1Sound")

@onready var fantasma_rojo = get_node("/root/Juego/FantasmaRojo")
@onready var fantasma_azul = get_node("/root/Juego/FantasmaAzul")
@onready var fantasma_rosa = get_node("/root/Juego/FantasmaRosa")
@onready var fantasma_naranja = get_node("/root/Juego/FantasmaNaranja")

@onready var puntos = get_node("/root/Juego/Puntos")

func _ready():
	anim_sprite.play("idle")	
	anim_sprite.stop()
	siren_1Sound.play()
	#anim_sprite.play("muerte")	
	#death_1Sound.play()

func _process(delta):
	if death:
		if !dying:
			anim_sprite.play("muerte")	
			death_1Sound.play()
		fantasma_rojo.visible = false
		fantasma_azul.visible = false
		fantasma_rosa.visible = false
		fantasma_naranja.visible = false
		dying = true
	else:
		handle_input()
		if moving:
			move_to_next_tile(delta)
	update_dots(delta)
	
func update_dots(delta):
	elapsed_time_dots += delta
	if elapsed_time_dots >= timer_duration_dots:
		elapsed_time_dots = 0
		for x in range(tile_map.get_used_rect().size.x):
			for y in range(tile_map.get_used_rect().size.y):
				var is_dot = false
				var pos = Vector2i(x, y)
				var cell_id = tile_map.get_cell_atlas_coords(0, pos)
				if cell_id == Vector2i(15,2):
					cell_id = Vector2i(14,2)
					is_dot = true
				elif cell_id == Vector2i(14,2):
					cell_id = Vector2i(15,2)
					is_dot = true
				if is_dot:
					tile_map.set_cell(0, pos, 0, cell_id)
					var global_pos = tile_map.map_to_local(pos)
					if is_collision_in_pos(global_pos, 6):
						eating_ghosts = true
						tile_map.set_cell(0, pos, 0, Vector2i(12,2))
						fantasma_rojo.scared = true
						fantasma_azul.scared = true
						fantasma_rosa.scared = true
						fantasma_naranja.scared = true


#	color_rect4.position = position
		
func handle_input():
	var input_direction = Vector2()
	if Input.is_action_pressed("ui_right"):
		input_direction.x = 1
	elif Input.is_action_pressed("ui_left"):
		input_direction.x = -1
	elif Input.is_action_pressed("ui_down"):
		input_direction.y = 1
	elif Input.is_action_pressed("ui_up"):
		input_direction.y = -1
	#print("input_direction", input_direction)

	if input_direction.length() > 0:
		var candidate_next_tile_position = position  + input_direction * tile_size
#		highlight_cell(color_rect1, candidate_next_tile_position)	
		if !is_wall(candidate_next_tile_position):
			# cuando se gira, corregir la posición para que siempre entre por el mismo punto
			if direction != input_direction:
					position.x = int(position.x / 8) * 8 + 4
					position.y = int(position.y / 8) * 8 + 4
			moving = true
			direction = input_direction.normalized()
			next_tile_position = candidate_next_tile_position
			#print("position ", position); 

	update_animation()


func move_to_next_tile(delta):
#	print("next_tile_position", next_tile_position)
	var next_position = position + direction * speed * delta
	if is_pellet(next_position) && !is_pellet(position):
		var cell_coords = tile_map.local_to_map(tile_map.to_local(next_position))
		tile_map.set_cell(0, cell_coords, 0, Vector2(12, 2))
		munch_1Sound.play()
		
	var distance_to_next_tile = next_tile_position - position
#	print("distance_to_next_tile", distance_to_next_tile)	
	if distance_to_next_tile.length() <= speed * (delta + 1):
		next_tile_position = position + direction * tile_size * 0.5

		if (is_wall(next_position) || is_wall(next_tile_position)):
			moving = false
		else:
			moving = true
			position = next_position
	else:
		position = next_position
	
	# Movimiento a través del túnel
	if position.x < 8:
		position.x = 220
	elif position.x >= 220:
		position.x = 8
		
	# Detectar colision con fantasmas
	if is_collision(fantasma_rojo) || is_collision(fantasma_azul) || is_collision(fantasma_naranja) || is_collision(fantasma_rosa):
		if eating_ghosts:
			var i = 0
			#puntos.position = position
		else:
			death = true
		
func cell_id_from_pos(pos: Vector2):
	var cell_coords = tile_map.local_to_map(tile_map.to_local(pos))
	var cell_id = tile_map.get_cell_atlas_coords(0, cell_coords)
	return cell_id
		
func is_wall(pos: Vector2):
	#print(cell_id.x, "#", cell_id.y)
	var cell_id = cell_id_from_pos(pos)
	if (cell_id.y == 2 && cell_id.x >= 12 && cell_id.x <= 15):
		#print("NO WALL")
		return false
	else:		
		return true
		
func is_pellet(pos: Vector2):
	#print(cell_id.x, "#", cell_id.y)
	var cell_id = cell_id_from_pos(pos)
	if (cell_id.y == 2 && cell_id.x == 13):
		return true
	else:		
		return false		
		
# Función para actualizar la animación basada en la dirección
func update_animation():
	if moving:
		if direction == Vector2(1, 0):
			anim_sprite.play("derecha")
		elif direction == Vector2(-1, 0):
			anim_sprite.play("izquierda")
		elif direction == Vector2(0, 1):
			anim_sprite.play("abajo")
		elif direction == Vector2(0, -1):
			anim_sprite.play("arriba")
	else:
		anim_sprite.pause()
		
func is_collision(sprite: CharacterBody2D):
	return is_collision_in_pos(sprite.position, 3)

func is_collision_in_pos(pos: Vector2i, size: int):
	if abs(position.x - pos.x) < size && abs(position.y - pos.y) < size:
		return true
	else:
		return false	
		
#func highlight_cell(rect: ColorRect, pos: Vector2):
#	var cell_coords = tile_map.local_to_map(tile_map.to_local(pos))
#	var cell_id = tile_map.get_cell_atlas_coords(0, cell_coords)
#	var world_position = tile_map.to_global(tile_map.map_to_local(cell_coords)) - tile_size * 0.5
#	if (!is_wall(world_position)):
#		rect.position = world_position
#	else:
#		rect.position = Vector2(-100,-100)

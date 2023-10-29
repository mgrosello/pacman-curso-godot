extends CharacterBody2D

var speed = 60  # Velocidad de Pac-Man
var direction = Vector2()  # Dirección actual de Pac-Man
var target_position = Vector2()
var target_position_izq = Vector2()
var target_position_der = Vector2()
var next_tile_position = Vector2()
var moving = false

@onready var anim_sprite = $Sprite2D/AnimationPlayer
@onready var tile_map = get_node("/root/Juego/TileMap")
@onready var tile_size = Vector2(tile_map.tile_set.tile_size)
@onready var color_rect1 = get_node("/root/Juego/ColorRect1")
@onready var color_rect2 = get_node("/root/Juego/ColorRect2")
@onready var color_rect3 = get_node("/root/Juego/ColorRect3")
@onready var color_rect4 = get_node("/root/Juego/ColorRect4")
@onready var color_rect5 = get_node("/root/Juego/ColorRect5")
@onready var color_rect6 = get_node("/root/Juego/ColorRect6")
@onready var siren_1Sound =get_node("/root/Juego/Siren_1Sound") 
@onready var munch_1Sound =get_node("/root/Juego/Munch_1Sound") 
@onready var munch_2Sound =get_node("/root/Juego/Munch_2Sound") 

func _ready():
	anim_sprite.play("idle")	
	anim_sprite.stop()
	siren_1Sound.play()

func _process(delta):
	handle_input()
	if moving:
		move_to_next_tile(delta)

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
		
#func highlight_cell(rect: ColorRect, pos: Vector2):
#	var cell_coords = tile_map.local_to_map(tile_map.to_local(pos))
#	var cell_id = tile_map.get_cell_atlas_coords(0, cell_coords)
#	var world_position = tile_map.to_global(tile_map.map_to_local(cell_coords)) - tile_size * 0.5
#	if (!is_wall(world_position)):
#		rect.position = world_position
#	else:
#		rect.position = Vector2(-100,-100)

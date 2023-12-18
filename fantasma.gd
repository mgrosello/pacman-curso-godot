extends CharacterBody2D

var speed = 60  # Velocidad de Pac-Man
var speed_scared = 40
var direction = Vector2()  
var next_tile_position = Vector2()


@onready var anim_sprite = $Sprite2D/AnimationPlayer
@onready var tile_map = get_node("/root/Juego/TileMap")
@onready var tile_size = Vector2(tile_map.tile_set.tile_size)

@export var color = 0
@export var moving = true
@export var scared = false
@export var dead = false

func _ready():
	direction = Vector2(-1, 0)
	next_tile_position = position + direction * tile_size
	
func _process(delta):
	if dead:
		position.x = 400
	elif moving:
		move_to_next_tile(delta)
	else:
		handle_movement()
		
	update_animation()
	#$Sprite2D.frame_coords.y = color
	
func handle_movement():
	var random_index = randi() % 4
	var input_direction = Vector2()

	if random_index == 0:
		input_direction.x = 1
	elif random_index == 1:
		input_direction.x = -1
	elif random_index == 2:
		input_direction.y = 1
	elif random_index == 3:
		input_direction.y = -1


	if input_direction.length() > 0:
		var candidate_next_tile_position = position + input_direction * tile_size
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


	
func move_to_next_tile(delta):
	var actual_speed = speed
	if scared:
		actual_speed = speed_scared
	var next_position = position + direction * actual_speed * delta
	var distance_to_next_tile = next_tile_position - position
#	print("distance_to_next_tile", distance_to_next_tile)	
	if distance_to_next_tile.length() <= actual_speed * (delta + 1):
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
		
		

# Función para actualizar la animación basada en la dirección
func update_animation():
	if scared:
		anim_sprite.play("aterrorizado")
	elif direction == Vector2(1, 0):
		anim_sprite.play("derecha_" + str(color))
	elif direction == Vector2(-1, 0):
		anim_sprite.play("izquierda_" + str(color))
	elif direction == Vector2(0, 1):
		anim_sprite.play("abajo_" + str(color))
	elif direction == Vector2(0, -1):
		anim_sprite.play("arriba_" + str(color))



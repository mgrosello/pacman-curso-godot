extends CharacterBody2D

var speed = 60  # Velocidad de Pac-Man
var direction = Vector2()  
var next_tile_position = Vector2()

var directions = [
  Vector2(0, -1), # Arriba
  Vector2(0, 1),  # Abajo
  Vector2(-1, 0), # Izquierda
  Vector2(1, 0)   # Derecha
]

@onready var anim_sprite = $Sprite2D/AnimationPlayer
@onready var tile_map = get_node("/root/Juego/TileMap")
@onready var tile_size = Vector2(tile_map.tile_set.tile_size)

func _ready():
	direction = Vector2(-1, 0)
	next_tile_position = position + direction * tile_size

func _process(delta):
	move_to_next_tile(delta)
	
func move_to_next_tile(delta):
	var next_position = position + direction * speed * delta
	var distance_to_next_tile = next_tile_position - position
	if distance_to_next_tile.length() <= speed * (delta + 1):
		next_tile_position = position + direction * tile_size * 0.5
		if (is_wall(next_position) || is_wall(next_tile_position)):
			# Elige una dirección aleatoria.
			var random_index = randi() % directions.size()
			direction = directions[random_index]
		else:
			position = next_position
	else:
		position = next_position
	
	# Movimiento a través del túnel
	if position.x < 8:
		position.x = 220
	elif position.x >= 220:
		position.x = 8
		
	update_animation()
		
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
	if direction == Vector2(1, 0):
		anim_sprite.play("derecha")
	elif direction == Vector2(-1, 0):
		anim_sprite.play("izquierda")
	elif direction == Vector2(0, 1):
		anim_sprite.play("abajo")
	elif direction == Vector2(0, -1):
		anim_sprite.play("arriba")

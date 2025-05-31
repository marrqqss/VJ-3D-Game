extends RigidBody3D

@onready var detector := $HitDetector
@export var powerup_chance: float = 0.1 # 10% de probabilidad de spawneo

# Variable estática compartida por todos los bloques
static var _initial_block_count := -1
static var _initialized := false

func _ready() -> void:
	add_to_group("blocks")
	gravity_scale = 1
	detector.body_entered.connect(Callable(self, "_on_body_entered"))
	
	# Esperar un frame para asegurarnos de que todos los bloques se han añadido a la escena
	await get_tree().process_frame
	
	# Solo el primer bloque inicializa el contador
	if not _initialized:
		_initialized = true
		_initial_block_count = get_tree().get_nodes_in_group("blocks").size()
		print("[DEBUG] Inicializando _initial_block_count:", _initial_block_count)
	

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("ball"):
		return

	print("ball")
	var my_pos: Vector3 = global_transform.origin

	# Obtener el recuento de bloques antes de destruir este
	var blocks = get_tree().get_nodes_in_group("blocks")
	var blocks_remaining = blocks.size() - 1
	
	# Asegurarse de que _initial_block_count es válido
	if _initial_block_count <= 0:
		_initial_block_count = blocks.size() # Usar el tamaño actual como fallback
	
	var destroyed_percent = 1.0 - float(blocks.size()) / float(_initial_block_count)
	print("[DEBUG] destroyed_percent:", destroyed_percent, "blocks.size():", blocks.size(), "_initial_block_count:", _initial_block_count)

	# Si toca el especial, ignora la probabilidad
	if destroyed_percent >= 0.93 and not GameState.complete_level_spawned:
		GameState.complete_level_spawned = true
		spawn_powerup(my_pos, true)
	elif randf() < powerup_chance:
		spawn_powerup(my_pos)

	GameState.add_score(500)
	
	# Verificar si este era el último bloque ANTES de destruirlo
	if blocks_remaining <= 0:
		print("[DEBUG] ¡Último bloque destruido! Avanzando al siguiente nivel...")
		# Primero nos removemos del grupo para evitar que otros bloques piensen que son el último
		remove_from_group("blocks")
		# Luego destruimos el bloque
		queue_free()
		# Finalmente avanzamos al siguiente nivel
		GameState.clean_level_objects()
		var next_map = GameState.advance_to_next_map()
		get_tree().call_deferred("change_scene_to_file", next_map)
	else:
		# Si no es el último bloque, simplemente lo destruimos
		queue_free()



func spawn_powerup(pos: Vector3, force_complete_level: bool = false) -> void:
	var powerup_scene
	var powerup
	# Buscar el nodo Player en la escena
	var player = get_tree().get_nodes_in_group("Player")[0]

	if force_complete_level:
		powerup_scene = load("res://scenes/complete_level.tscn")
		powerup = powerup_scene.instantiate()
		powerup.transform.origin = pos
		get_tree().current_scene.add_child(powerup)
		return

	var powerup_types = [
		"res://scenes/expand_paddle.tscn",
		"res://scenes/power_ball.tscn",
		"res://scenes/reduce_paddle.tscn",
		"res://scenes/magnet.tscn",
		"res://scenes/extra_balls.tscn",
		"res://scenes/slow_ball.tscn",
		"res://scenes/speed_ball.tscn",
		"res://scenes/explosive_ball.tscn"
	]
	if player._power_ball_active:
		powerup_types.append("res://scenes/normal_ball.tscn")
	powerup_scene = load(powerup_types[randi() % powerup_types.size()])
	powerup = powerup_scene.instantiate()
	powerup.transform.origin = pos
	get_tree().current_scene.add_child(powerup)

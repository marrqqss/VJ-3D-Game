extends RigidBody3D

@onready var detector := $HitDetector
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var powerup_chance: float = 0.1 # 10% de probabilidad de spawneo

# Variable estática compartida por todos los bloques
static var _initial_block_count := -1
static var _initialized := false

func _ready() -> void:
	add_to_group("blocks")
	gravity_scale = 1
	detector.body_entered.connect(Callable(self, "_on_body_entered"))
	
	# Reiniciar la variable de avance de nivel
	_level_advancing = false
	
	# Esperar un frame para asegurarnos de que todos los bloques se han añadido a la escena
	await get_tree().process_frame
	
	# Solo el primer bloque inicializa el contador
	if not _initialized:
		_initialized = true
		_initial_block_count = get_tree().get_nodes_in_group("blocks").size()
		print("[DEBUG] Inicializando _initial_block_count:", _initial_block_count)
	

# Variable estática para evitar que múltiples bloques activen el avance de nivel
static var _level_advancing := false

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("ball") or _level_advancing:
		return

	print("ball")
	var my_pos: Vector3 = global_transform.origin

	# Obtener el recuento de bloques antes de destruir este
	var blocks = get_tree().get_nodes_in_group("blocks")
	var blocks_remaining = blocks.size() - 1
	
	# Asegurarse de que _initial_block_count es válido
	if _initial_block_count <= 0:
		_initial_block_count = blocks.size()
	
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
		# Marcar que el nivel ya está avanzando para evitar que otros bloques lo activen
		_level_advancing = true
		# Remover del grupo y destruir
		remove_from_group("blocks")
		queue_free()
		# Limpiar objetos y avanzar nivel
		GameState.clean_level_objects()
		var next_map = GameState.advance_to_next_map()
		get_tree().call_deferred("change_scene_to_file", next_map)
	else:
		animation_player.play("destroy")


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

extends RigidBody3D

@onready var detector := $HitDetector
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var powerup_chance: float = 0.1 # 10% de probabilidad de spawneo
@export var color : Color = Color.RED

# Variable estática compartida por todos los bloques
static var _initial_block_count := -1
static var _initialized := false
static var _current_level := -1

func _ready() -> void:
	add_to_group("blocks")
	gravity_scale = 1
	detector.body_entered.connect(Callable(self, "_on_body_entered"))
	
	# Conectar la señal de finalización de animación
	animation_player.animation_finished.connect(Callable(self, "_on_animation_finished"))
	
	# Reiniciar la variable de avance de nivel
	_level_advancing = false
	
	# Esperar un frame para asegurarnos de que todos los bloques se han añadido a la escena
	await get_tree().process_frame
	
	# Verificar si hemos cambiado de nivel
	var current_level = GameState.current_map_index
	if _current_level != current_level:
		_current_level = current_level
		_initialized = false
		print("[DEBUG] Cambio de nivel detectado. Reiniciando inicialización.")
	
	# Solo el primer bloque inicializa el contador para este nivel
	if not _initialized:
		_initialized = true
		_initial_block_count = get_tree().get_nodes_in_group("blocks").size()
		print("[DEBUG] Inicializando _initial_block_count para nivel ", _current_level, ": ", _initial_block_count)
	

# Variable estática para evitar que múltiples bloques activen el avance de nivel
static var _level_advancing := false

# Función estática para reiniciar variables cuando se cambia de nivel
static func reset_static_vars():
	_initialized = false
	_initial_block_count = -1
	_level_advancing = false
	print("[DEBUG] Variables estáticas de bloques reiniciadas")

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("ball") or _level_advancing:
		return

	print("ball")
	spawn_destruction_particles(color)
	var my_pos: Vector3 = global_transform.origin

	# Obtener el recuento de bloques antes de destruir este
	var blocks = get_tree().get_nodes_in_group("blocks")
	var blocks_remaining = blocks.size() - 1  # Restamos 1 porque este bloque está a punto de ser eliminado
	
	# Asegurarse de que _initial_block_count es válido
	if _initial_block_count <= 0:
		_initial_block_count = blocks.size()
	
	var destroyed_percent = 1.0 - float(blocks.size()) / float(_initial_block_count)
	print("[DEBUG] destroyed_percent:", destroyed_percent, " blocks.size():", blocks.size(), " _initial_block_count:", _initial_block_count, " blocks_remaining:", blocks_remaining)

	# Si toca el especial, ignora la probabilidad
	if destroyed_percent >= 0.9 and not GameState.complete_level_spawned:
		GameState.complete_level_spawned = true
		spawn_powerup(my_pos, true)
	elif randf() < powerup_chance:
		spawn_powerup(my_pos)

	GameState.add_score(500)
	
	# Remover este bloque del grupo para que no se cuente en futuras verificaciones
	remove_from_group("blocks")
	
	# Verificar si este era el último bloque
	if blocks_remaining <= 0:
		print("[DEBUG] ¡Último bloque destruido! Avanzando al siguiente nivel...")
		# Marcar que el nivel está avanzando para evitar múltiples activaciones
		_level_advancing = true
		# Limpiar objetos y avanzar nivel
		GameState.clean_level_objects()
		var next_map = GameState.advance_to_next_map()
		get_tree().call_deferred("change_scene_to_file", next_map)
		queue_free()
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

func spawn_destruction_particles(color: Color) -> void:
	var particle_scene = preload("res://scenes/break_block.tscn")
	var particle_instance = particle_scene.instantiate()
	particle_instance.global_transform.origin = global_transform.origin
	get_tree().root.add_child(particle_instance)
	particle_instance.break_block_particles(color)

# Función que se llama cuando termina una animación
func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "destroy":
		# Verificar si todavía hay bloques después de la animación
		var remaining_blocks = get_tree().get_nodes_in_group("blocks").size()
		print("[DEBUG] Bloques restantes después de animación: ", remaining_blocks)
		
		# Si este era el último bloque, avanzar al siguiente nivel
		if remaining_blocks <= 0 and not _level_advancing:
			print("[DEBUG] ¡Último bloque destruido después de animación! Avanzando al siguiente nivel...")
			_level_advancing = true
			# Limpiar objetos y avanzar nivel
			GameState.clean_level_objects()
			var next_map = GameState.advance_to_next_map()
			# Usar call_deferred para asegurar que todo se actualice correctamente
			get_tree().call_deferred("change_scene_to_file", next_map)
		
		# Destruir este bloque en cualquier caso
		queue_free()

extends Node

signal score_changed(new_score: int)
var puntuation : int = 0
var map1_puntuation : int = 0
var map2_puntuation : int = 0
var map3_puntuation : int = 0
var map4_puntuation : int = 0
var map5_puntuation : int = 0

# Procesa input global para cambio de mapas con teclas 1-5
func _process(_delta):
	if Input.is_action_just_pressed("change_map1"):
		load_and_change_map(0)
	if Input.is_action_just_pressed("change_map2"):
		load_and_change_map(1)
	if Input.is_action_just_pressed("change_map3"):
		load_and_change_map(2)
	if Input.is_action_just_pressed("change_map4"):
		load_and_change_map(3)
	if Input.is_action_just_pressed("change_map5"):
		load_and_change_map(4)

# Limpia todos los objetos del nivel (bolas, powerups, bloques)
func clean_level_objects() -> void:
	# Limpia la escena actual
	for ball in get_tree().get_nodes_in_group("ball"):
		if is_instance_valid(ball):
			ball.queue_free()
	for pu in get_tree().get_nodes_in_group("powerups"):
		if is_instance_valid(pu):
			pu.queue_free()
	for block in get_tree().get_nodes_in_group("blocks"):
		if is_instance_valid(block):
			block.queue_free()

# Cambia al mapa especificado y limpia la escena actual
func load_and_change_map(index: int) -> void:
	# Limpia la escena actual
	clean_level_objects()
	
	# Carga el mapa seleccionado
	var map_path = load_map_by_index(index)
	if map_path != "":
		get_tree().call_deferred("change_scene_to_file", map_path)

var complete_level_spawned := false

# Lista de mapas para progresión dinámica
var maps := [
	"res://scenes/map1.tscn",
	"res://scenes/map2.tscn",
	"res://scenes/map3.tscn",
	"res://scenes/map4.tscn",
	"res://scenes/map5.tscn"
]
var current_map_index := 0

func add_score(points: int) -> void:
	puntuation += points
	emit_signal("score_changed", puntuation)

func reset_level_flags():
	complete_level_spawned = false

# Llama esto al iniciar partida o volver al menú
func reset_progression():
	current_map_index = 0
	reset_level_flags()

# Llama esto cuando el jugador recoge complete_level
func advance_to_next_map() -> String:
	if current_map_index == 0 && puntuation > map1_puntuation:
		map1_puntuation = puntuation
		print(map1_puntuation)
	if current_map_index == 1 && puntuation > map2_puntuation:
		map2_puntuation = puntuation
		print(map2_puntuation)
	if current_map_index == 2 && puntuation > map3_puntuation:
		map3_puntuation = puntuation
		print(map3_puntuation)
	if current_map_index == 3 && puntuation > map4_puntuation:
		map4_puntuation = puntuation
		print(map4_puntuation)
	if current_map_index == 4 && puntuation > map5_puntuation:
		map5_puntuation = puntuation
		print(map5_puntuation)
	puntuation = 0
	current_map_index += 1
	reset_level_flags()
	if current_map_index < maps.size():
		return maps[current_map_index]
	return ""

# Devuelve el mapa actual
func get_current_map() -> String:
	return maps[current_map_index]

# Carga un mapa específico por índice (0-4 para map1-map5)
func load_map_by_index(index: int) -> String:
	if index >= 0 and index < maps.size():
		current_map_index = index
		reset_level_flags()
		return maps[current_map_index]
	return ""

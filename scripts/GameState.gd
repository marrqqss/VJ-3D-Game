extends Node

signal score_changed(new_score: int)
var puntuation : int = 0
var map1_puntuation : int = 0
var map2_puntuation : int = 0
var map3_puntuation : int = 0
var map4_puntuation : int = 0
var map5_puntuation : int = 0

var save_file_path := "user://arkanoid3D_save_game.json"

func _ready():
	load_saved_scores()

# Procesa input global para cambio de mapas con teclas 1-5
func _process(_delta):
	if Input.is_action_just_pressed("change_map1"):
		save_state()
		load_and_change_map(0)
	if Input.is_action_just_pressed("change_map2"):
		save_state()
		load_and_change_map(1)
	if Input.is_action_just_pressed("change_map3"):
		save_state()
		load_and_change_map(2)
	if Input.is_action_just_pressed("change_map4"):
		save_state()
		load_and_change_map(3)
	if Input.is_action_just_pressed("change_map5"):
		save_state()
		load_and_change_map(4)
	if Input.is_action_just_pressed("go_to_title_screen"):
		save_state()
		load_and_change_map(6)

# Limpia todos los objetos del nivel (bolas, powerups, bloques)
func clean_level_objects() -> void:
	for ball in get_tree().get_nodes_in_group("ball"):
		if is_instance_valid(ball):
			ball.queue_free()
	for pu in get_tree().get_nodes_in_group("powerups"):
		if is_instance_valid(pu):
			pu.queue_free()
	for block in get_tree().get_nodes_in_group("blocks"):
		if is_instance_valid(block):
			block.queue_free()

func load_and_change_map(index: int) -> void:
	clean_level_objects()
	current_map_index = index
	# Resetear la puntuación al cambiar de mapa manualmente
	puntuation = 0
	emit_signal("score_changed", puntuation)
	var map_path = load_map_by_index(index)
	if map_path != "":
		get_tree().call_deferred("change_scene_to_file", map_path)

var complete_level_spawned := false
var maps := [
	"res://scenes/map1.tscn",
	"res://scenes/map2.tscn",
	"res://scenes/map3.tscn",
	"res://scenes/map4.tscn",
	"res://scenes/map5.tscn",
	"res://scenes/credits.tscn",
	"res://scenes/main_menu.tscn"
]
var current_map_index := 0

func add_score(points: int) -> void:
	puntuation += points
	emit_signal("score_changed", puntuation)

func reset_level_flags():
	complete_level_spawned = false

func reset_progression():
	current_map_index = 0
	reset_level_flags()

func advance_to_next_map() -> String:
	save_state()
	current_map_index += 1
	reset_level_flags()
	# Asegurarse de que la puntuación se resetea al avanzar de nivel
	puntuation = 0
	emit_signal("score_changed", puntuation)
	if current_map_index < maps.size():
		print(current_map_index)
		print(maps.size())
		return maps[current_map_index]
	return ""

func save_state() -> void:
	# Guardar la puntuación más alta para cada mapa
	if current_map_index == 0 && puntuation > map1_puntuation:
		map1_puntuation = puntuation
	if current_map_index == 1 && puntuation > map2_puntuation:
		map2_puntuation = puntuation
	if current_map_index == 2 && puntuation > map3_puntuation:
		map3_puntuation = puntuation
	if current_map_index == 3 && puntuation > map4_puntuation:
		map4_puntuation = puntuation
	if current_map_index == 4 && puntuation > map5_puntuation:
		map5_puntuation = puntuation
	# No resetear la puntuación aquí, solo guardar el archivo
	save_scores_to_file()

func save_scores_to_file():
	var data = {
		"map1": map1_puntuation,
		"map2": map2_puntuation,
		"map3": map3_puntuation,
		"map4": map4_puntuation,
		"map5": map5_puntuation
	}
	var file = FileAccess.open(save_file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

func load_saved_scores():
	if FileAccess.file_exists(save_file_path):
		var file = FileAccess.open(save_file_path, FileAccess.READ)
		if file:
			var data = JSON.parse_string(file.get_as_text())
			if typeof(data) == TYPE_DICTIONARY:
				map1_puntuation = data.get("map1", 0)
				map2_puntuation = data.get("map2", 0)
				map3_puntuation = data.get("map3", 0)
				map4_puntuation = data.get("map4", 0)
				map5_puntuation = data.get("map5", 0)
			file.close()

func get_current_map() -> String:
	return maps[current_map_index]

func load_map_by_index(index: int) -> String:
	if index >= 0 and index < maps.size():
		current_map_index = index
		reset_level_flags()
		return maps[current_map_index]
	return ""

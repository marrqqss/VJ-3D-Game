extends Node

signal score_changed(new_score: int)
var puntuation : int = 0

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
	puntuation = 0
	current_map_index += 1
	reset_level_flags()
	if current_map_index < maps.size():
		return maps[current_map_index]
	return ""

# Devuelve el mapa actual
func get_current_map() -> String:
	return maps[current_map_index]

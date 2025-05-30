extends VBoxContainer

const map1 = preload("res://scenes/map1.tscn")

func _process(delta: float) -> void:
	$"../Puntuations2/puntuation1".text = str(GameState.map1_puntuation)
	$"../Puntuations2/puntuation2".text = str(GameState.map2_puntuation)
	$"../Puntuations2/puntuation3".text = str(GameState.map3_puntuation)
	$"../Puntuations2/puntuation4".text = str(GameState.map4_puntuation)
	$"../Puntuations2/puntuation5".text = str(GameState.map5_puntuation)

func _on_start_game_pressed() -> void:
	GameState.current_map_index = 0
	get_tree().change_scene_to_packed(map1)
	pass

func _on_exit_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.

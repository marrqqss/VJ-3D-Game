extends VBoxContainer

const map1 = preload("res://scenes/map1.tscn")

func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_packed(map1)
	pass

func _on_exit_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.

extends CanvasLayer


func _ready() -> void:
	# Inicializar puntuación
	$Points.text = str(GameState.puntuation)
	GameState.connect("score_changed", Callable(self, "_on_score_changed"))
	
	# Inicializar vidas
	$Lives.text = "Lives: " + str(GameState.player_lives)
	GameState.connect("lives_changed", Callable(self, "_on_lives_changed"))

func _on_score_changed(new_score: int) -> void:
	$Points.text = str(new_score)
	
func _on_lives_changed(new_lives: int) -> void:
	$Lives.text = "Lives: " + str(new_lives)

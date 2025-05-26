extends CanvasLayer


func _ready() -> void:
	$Points.text = str(GameState.puntuation)
	GameState.connect("score_changed", Callable(self, "_on_score_changed"))

func _on_score_changed(new_score: int) -> void:
	$Points.text = str(new_score)

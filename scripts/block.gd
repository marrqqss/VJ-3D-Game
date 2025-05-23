extends RigidBody3D

@onready var detector := $HitDetector
@export var powerup_chance: float = 0.3 # 30% de probabilidad de spawneo

func _ready() -> void:
	add_to_group("blocks")
	gravity_scale = 1
	detector.body_entered.connect(Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("ball"):
		return
	
	print("ball")
	var my_pos: Vector3 = global_transform.origin
	
	# Añade probabilidad de generar  power-up
	if randf() < powerup_chance:
		spawn_powerup(my_pos)
	
	queue_free()

func spawn_powerup(pos: Vector3) -> void:
	var powerup_types = [
		"res://scenes/expand_paddle.tscn",
		"res://scenes/power_ball.tscn",
		"res://scenes/reduce_paddle.tscn",
		"res://scenes/magnet.tscn",
		"res://scenes/extra_balls.tscn"
	]
	
	# Seleccionar un tipo aleatorio
	var powerup_scene = load(powerup_types[randi() % powerup_types.size()])
	var powerup = powerup_scene.instantiate()
	
	# Posiciona el powerup en la ubicación del bloque
	powerup.transform.origin = pos
	
	# Añade el powerup a la escena actual
	get_tree().current_scene.add_child(powerup)

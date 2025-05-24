extends RigidBody3D

@onready var detector := $HitDetector
@export var powerup_chance: float = 0.3 # 30% de probabilidad de spawneo

var _initial_block_count := -1
var _complete_level_spawned := false

func _ready() -> void:
	add_to_group("blocks")
	gravity_scale = 1
	detector.body_entered.connect(Callable(self, "_on_body_entered"))
	if _initial_block_count == -1:
		_initial_block_count = get_tree().get_nodes_in_group("blocks").size()
	

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("ball"):
		return

	print("ball")
	var my_pos: Vector3 = global_transform.origin

	var blocks = get_tree().get_nodes_in_group("blocks")
	var destroyed_percent = 1.0 - float(blocks.size()) / float(_initial_block_count)

	# Si toca el especial, ignora la probabilidad
	if destroyed_percent >= 0.95 and not _complete_level_spawned:
		spawn_powerup(my_pos)
	elif randf() < powerup_chance:
		spawn_powerup(my_pos)

	queue_free()

func spawn_powerup(pos: Vector3) -> void:
	var powerup_scene
	var powerup
	# Buscar el nodo Player en la escena
	var player = get_tree().get_nodes_in_group("Player")[0]
	var blocks = get_tree().get_nodes_in_group("blocks")
	# Calcular porcentaje de bloques destruidos
	if _initial_block_count == -1:
		_initial_block_count = blocks.size()
	var destroyed_percent = 1.0 - float(blocks.size()) / float(_initial_block_count)
	# Si se ha destruido el 95% y aún no se ha spawneado el powerup especial
	if destroyed_percent >= 0.95 and not _complete_level_spawned:
		_complete_level_spawned = true
		powerup_scene = load("res://scenes/complete_level.tscn")
		powerup = powerup_scene.instantiate()
		powerup.transform.origin = pos
		get_tree().current_scene.add_child(powerup)
		return
	# Si no, seguir con el sistema normal de powerups
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

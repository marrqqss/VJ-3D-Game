extends RigidBody3D

@onready var detector := $HitDetector
@export var powerup_chance: float = 0.2 # 20% de probabilidad de spawneo

var _initial_block_count := -1

func _ready() -> void:
	add_to_group("blocks")
	gravity_scale = 1
	detector.body_entered.connect(Callable(self, "_on_body_entered"))
	if _initial_block_count == -1:
		var count = get_tree().get_nodes_in_group("blocks").size()
		print("[DEBUG] Inicializando _initial_block_count:", count)
		_initial_block_count = count
	

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("ball"):
		return

	print("ball")
	var my_pos: Vector3 = global_transform.origin

	var blocks = get_tree().get_nodes_in_group("blocks")
	var destroyed_percent = 1.0 - float(blocks.size()) / float(_initial_block_count)
	print("[DEBUG] destroyed_percent:", destroyed_percent, "blocks.size():", blocks.size(), "_initial_block_count:", _initial_block_count)

	# Si toca el especial, ignora la probabilidad
	if destroyed_percent >= 0.95 and not GameState.complete_level_spawned:
		if _initial_block_count > 0:
			print("[DEBUG] Spawneando complete_level")
			GameState.complete_level_spawned = true
			spawn_powerup(my_pos, true)
		else:
			print("[DEBUG] No se puede spawnear complete_level: _initial_block_count <= 0")
	elif randf() < powerup_chance:
		spawn_powerup(my_pos)

	queue_free()


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

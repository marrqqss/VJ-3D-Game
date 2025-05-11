extends Area3D

@export var fall_speed: float = 5.0
@export var rotation_speed: float = 2.0
@export var powerup_type: String = "expand_paddle"

func _ready() -> void:
	add_to_group("powerups")
	body_entered.connect(Callable(self, "_on_body_entered"))

func _process(delta: float) -> void:
	# Mover hacia la paleta en Z positivo (ajusta según tu escena)
	global_transform.origin.z += fall_speed * delta
	
	# Rotación para efecto visual
	rotate_y(rotation_speed * delta)
	
	# Eliminar si cae fuera del área
	if global_transform.origin.z > 10.0:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		apply_powerup(body)
		queue_free()

func apply_powerup(player: Node) -> void:
	# Implementa el efecto según el tipo
	match powerup_type:
		"expand_paddle":
			player.scale.x = 1.5
			# Opcional: temporizador para revertir
			var timer = get_tree().create_timer(10.0)
			timer.timeout.connect(func(): player.scale.x = 1.0)
		# Añade más tipos según necesites

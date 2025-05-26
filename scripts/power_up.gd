extends Area3D

@export var fall_speed: float = 5.0
@export var rotation_speed: float = 2.0
@export var powerup_type: String = "expand_paddle"

# Variables para el efecto de rebote
@export var initial_bounce_height: float = 10.0
@export var bounce_damping: float = 0.6
var y_velocity: float = 0.0
var bounce_gravity: float = 15.0  
var is_bouncing: bool = true
var original_y: float = 0.0
var timer = 0

func _ready() -> void:
	add_to_group("powerups")
	body_entered.connect(Callable(self, "_on_body_entered"))
	
	# Guardar posición Y inicial y dar impulso hacia arriba
	original_y = global_transform.origin.y
	y_velocity = initial_bounce_height

func _process(delta: float) -> void:
	# Aplicar rotación visual
	rotate_y(rotation_speed * delta)
	if is_bouncing:
		# Simular gravedad
		y_velocity -= bounce_gravity * delta
		
		# Actualizar posición Y
		global_transform.origin.y += y_velocity * delta
		
		# Detectar rebote con el "suelo"
		if global_transform.origin.y <= original_y:
			global_transform.origin.y = original_y
			y_velocity = -y_velocity * bounce_damping
			
			# Si el rebote es muy pequeño, detener el efecto
			if abs(y_velocity) < 0.5:
				is_bouncing = false
				global_transform.origin.y = original_y
	
	# Siempre mover hacia la paleta (en Z)
	global_transform.origin.z += fall_speed * delta
	
	# Eliminar si cae fuera del área
	if global_transform.origin.z > 17.0:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		apply_powerup(body)
		queue_free()

func apply_powerup(player: Node) -> void:
	match powerup_type:
		"expand_paddle":
			player.expand_paddle()
		"reduce_paddle":
			player.reduce_paddle()
		"power_ball":
			player.power_ball()
		"magnet":
			player.activate_magnet()
		"extra_balls":
			var balls = get_tree().get_nodes_in_group("ball")
			for ball in balls:
				ball.spawn_extra_balls()
		"slow_ball":
			var balls = get_tree().get_nodes_in_group("ball")
			for ball in balls:
				ball.SPEED *= 0.8  # Reduce speed by 20%
		"speed_ball":
			var balls = get_tree().get_nodes_in_group("ball")
			for ball in balls:
				ball.SPEED *= 1.2  # Increase speed by 20%
		"normal_ball":
			if player._power_ball_active:
				player.normal_ball()
		"explosive_ball":
			var balls = get_tree().get_nodes_in_group("ball")
			for ball in balls:
				if ball.has_method("set_explosive_ball"):
					ball.set_explosive_ball()
		"complete_level":
			# Limpia todos los objetos del nivel usando la función centralizada
			GameState.clean_level_objects()
			
			# Progresión dinámica: avanza al siguiente mapa
			var next_map = GameState.advance_to_next_map()
			if next_map != "":
				get_tree().call_deferred("change_scene_to_file", next_map)
			else:
				# Si no hay más mapas, volver al menú o pantalla final
				get_tree().call_deferred("change_scene_to_file", "res://scenes/main_menu.tscn")

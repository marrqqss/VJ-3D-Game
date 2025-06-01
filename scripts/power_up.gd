extends Area3D

@export var fall_speed: float = 5.0
@export var rotation_speed: float = 2.0
@export var powerup_type: String = "expand_paddle"
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Altura del suelo
@export var floor_height: float = 1.5

# Variables para el efecto de rebote
@export var initial_bounce_height: float = 10.0
@export var bounce_damping: float = 0.6
var y_velocity: float = 0.0
var bounce_gravity: float = 15.0  
var is_bouncing: bool = true
var original_y: float = 0.0
var is_falling_to_floor: bool = false
var fall_to_floor_speed: float = 10.0

func _ready() -> void:
	add_to_group("powerups")
	body_entered.connect(Callable(self, "_on_body_entered"))
	
	# Guardar la posición Y original para referencia
	var spawn_y = global_transform.origin.y
	
	# Verificar si el powerup está por encima del suelo
	if spawn_y > floor_height + 0.5:
		# Si está muy por encima, primero caerá hasta el suelo
		is_falling_to_floor = true
		is_bouncing = false
	else:
		# Si ya está cerca del suelo, ajustar a la altura correcta e iniciar el rebote
		global_transform.origin.y = floor_height
		original_y = floor_height
		y_velocity = initial_bounce_height

func _process(delta: float) -> void:
	# Aplicar rotación visual
	rotate_y(rotation_speed * delta)
	
	if is_falling_to_floor:
		# Caer hacia el suelo rápidamente
		global_transform.origin.y -= fall_to_floor_speed * delta
		
		# Cuando llegue al suelo, iniciar el rebote
		if global_transform.origin.y <= floor_height:
			global_transform.origin.y = floor_height
			is_falling_to_floor = false
			is_bouncing = true
			original_y = floor_height
			y_velocity = initial_bounce_height
			
	elif is_bouncing:
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
		print("PICKUP")
		animation_player.play("pickup")
		

func apply_powerup(player: Node) -> void:
	match powerup_type:
		"expand_paddle":
			GameState.add_score(1000)
			player.expand_paddle()
		"reduce_paddle":
			GameState.add_score(5000)
			player.reduce_paddle()
		"power_ball":
			GameState.add_score(2500)
			player.power_ball()
		"magnet":
			GameState.add_score(2500)
			player.activate_magnet()
		"extra_balls":
			GameState.add_score(3500)
			var balls = get_tree().get_nodes_in_group("ball")
			for ball in balls:
				ball.spawn_extra_balls()
		"slow_ball":
			GameState.add_score(3000)
			var balls = get_tree().get_nodes_in_group("ball")
			for ball in balls:
				ball.SPEED *= 0.8  # Reduce speed by 20%
		"speed_ball":
			GameState.add_score(6000)
			var balls = get_tree().get_nodes_in_group("ball")
			for ball in balls:
				ball.SPEED *= 1.2  # Increase speed by 20%
		"normal_ball":
			GameState.add_score(5000)
			if player._power_ball_active:
				player.normal_ball()
		"explosive_ball":
			GameState.add_score(3000)
			var balls = get_tree().get_nodes_in_group("ball")
			for ball in balls:
				if ball.has_method("set_explosive_ball"):
					ball.set_explosive_ball()
		"complete_level":
			GameState.add_score(7500)
			# Limpia todos los objetos del nivel usando la función centralizada
			GameState.clean_level_objects()
			
			# Progresión dinámica: avanza al siguiente mapa
			var next_map = GameState.advance_to_next_map()
			if next_map != "":
				get_tree().call_deferred("change_scene_to_file", next_map)
			else:
				# Si no hay más mapas, volver al menú o pantalla final
				get_tree().call_deferred("change_scene_to_file", "res://scenes/main_menu.tscn")

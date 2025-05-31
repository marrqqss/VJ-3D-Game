extends CharacterBody3D

@export var SPEED: float = 15.0
@export var BOUNCE: float = 1.0
@export var attach_offset: Vector3 = Vector3(0, 0, -1)
@export var ROTATION_SPEED: float = 0.4  
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

var launched: bool = false
var direction: Vector3 = Vector3(0, 0, 1)
var power_ball_mode: bool = false
var current_rotation: float = 0.0

var is_attached_to_paddle: bool = false
var collision_offset: Vector3 = Vector3.ZERO
var last_direction: Vector3 = Vector3.ZERO



func _ready() -> void:
	add_to_group("ball")
	velocity = Vector3.ZERO

func set_power_ball(active: bool) -> void:
	power_ball_mode = false
	explosive_mode = false
	
	power_ball_mode = active
	

# Límite Z más allá del cual la bola se destruirá
@export var out_of_bounds_z: float = 17.0

func _physics_process(delta: float) -> void:
	if is_attached_to_paddle:
		# Mantener posición y contrarrestar la escala del paddle
		var parent = get_parent()
		global_transform.origin = parent.global_transform.origin + collision_offset
		scale = Vector3(1.0 / parent.scale.x, 1.0, 1.0)  # Invertir escala X del paddle
		return
	if not launched:
  
		#lock to player
		var paddle_transform = get_parent().global_transform
		global_transform.origin = paddle_transform.origin + attach_offset

		if Input.is_action_just_pressed("ui_accept"):
			# — launch ball —
			var saved_tf = global_transform
			var root = get_tree().get_current_scene()
			get_parent().remove_child(self)
			root.add_child(self)
			global_transform = saved_tf
			launched = true

			var move_input = Input.get_axis("ui_left", "ui_right")
			direction = Vector3(move_input, 0, -1).normalized()
			velocity  = direction * SPEED

	else:
		# 1. Reset velocity to exact SPEED in the desired direction
		velocity = direction * SPEED

		# 2. Let the physics engine move & slide
		move_and_slide()

		# 3. Clamp back to exact SPEED  
		#    (whatever tiny loss happened internally is wiped out)
		velocity = velocity.normalized() * SPEED
		  # ROTACIÓN BOLA
		if velocity.length() > 0.01:
			mesh_instance.look_at(global_position + velocity, Vector3.UP)
			current_rotation -= velocity.length() * delta * ROTATION_SPEED
			mesh_instance.rotate_object_local(Vector3(1, 0, 0), current_rotation - mesh_instance.rotation.x)
		
		# Verificar si la bola está fuera de los límites
		check_out_of_bounds()

		var col = get_last_slide_collision()
		if col:
			var normal = col.get_normal()
			var collider = col.get_collider()

			# --- EXPLOSIVE BALL LOGIC ---
			if explosive_mode and collider.is_in_group("blocks"):
				# Eliminar todos los bloques cercanos
				var explosion_radius = 3.5
				var blocks = get_tree().get_nodes_in_group("blocks")
				for block in blocks:
					if block.global_transform.origin.distance_to(col.get_position()) <= explosion_radius:
						if block != collider:
							block._on_body_entered(self)
				# Rebote normal después de explosión
				direction = direction.bounce(col.get_normal()) * BOUNCE
				direction = direction.normalized()
				return

			if power_ball_mode and collider.is_in_group("blocks"):
				# Power Ball: no rebotar
				pass
				
			elif collider.is_in_group("Player"):
				if collider.magnet_active:
					last_direction = direction
					var local_hit = collider.to_local(col.get_position())
					collision_offset = Vector3(local_hit.x, 0, -1)
					var previous_global = global_transform
					get_parent().remove_child(self)
					collider.add_child(self)
					global_transform = previous_global
					is_attached_to_paddle = true
					velocity = Vector3.ZERO
				else:
					# Rebote NORMAL con paleta
					var local_hit = col.get_position() - collider.global_transform.origin
					var pad_shape = collider.get_node("CollisionShape3D").shape
					var half_width = pad_shape.extents.x
					var factor = clamp(local_hit.x / half_width, -1, 1)
					direction.x = factor
					direction.z = -abs(direction.z)
					direction = direction.normalized()
			
			else:
				# Rebote con otros objetos (paredes, etc)
				direction = direction.bounce(col.get_normal()) * BOUNCE
				direction = direction.normalized()


var explosive_mode: bool = false

func set_explosive_ball() -> void:
	# Reset all power-up modes first
	power_ball_mode = false
	explosive_mode = false
	
	# Then activate the requested mode
	explosive_mode = true

func launch_from_paddle():
	var parent = get_parent()
	var previous_global = global_transform
	
	# Calcular dirección basada en el offset LOCAL
	var launch_dir = -last_direction.normalized()
	
	# Reparentear de forma segura
	parent.call_deferred("remove_child", self)
	get_tree().root.call_deferred("add_child", self)
	
	# Asegurar que se aplican los cambios en el próximo frame
	call_deferred("_finish_launch", previous_global, launch_dir)

func _finish_launch(previous_global: Transform3D, launch_dir: Vector3):
	global_transform = previous_global
	direction = launch_dir
	velocity = direction * SPEED
	is_attached_to_paddle = false
	launched = true
	
# Función para verificar si la bola está fuera de los límites
func check_out_of_bounds() -> void:
	# Verificar si la bola ha ido más allá del límite Z
	if global_transform.origin.z > out_of_bounds_z:
		# Si es la última bola, perder una vida y respawnear en el jugador
		var balls = get_tree().get_nodes_in_group("ball")
		if balls.size() <= 1:
			# Reducir una vida
			var has_lives_left = GameState.lose_life()
			
			# Si aún quedan vidas, respawnear la bola
			if has_lives_left:
				# Buscar al jugador
				var players = get_tree().get_nodes_in_group("Player")
				if players.size() > 0:
					# Resetear la bola en lugar de destruirla
					var player = players[0]
					
					# Reparentear la bola al jugador
					var current_parent = get_parent()
					if current_parent != player:
						current_parent.remove_child(self)
						player.add_child(self)
					
					# Resetear estado
					launched = false
					velocity = Vector3.ZERO
					is_attached_to_paddle = false
					power_ball_mode = false
					explosive_mode = false
					
					# Posicionar correctamente
					global_transform.origin = player.global_transform.origin + attach_offset
				else:
					# No hay jugador, destruir la bola
					queue_free()
			else:
				# No quedan vidas, la bola se destruye (GameState ya se encarga de ir al menú)
				queue_free()
		else:
			# Hay más bolas, simplemente destruir esta
			queue_free()
	
	
func spawn_extra_balls():
	var angles = [30, -30]
	var ball_scene = load("res://scenes/ball.tscn")
	
	for angle in angles:
		var new_ball = ball_scene.instantiate()
		new_ball.add_to_group("ball")
		
		
		new_ball.collision_layer = collision_layer
		new_ball.collision_mask = collision_mask    
		
		
		new_ball.global_transform = global_transform
		
		
		new_ball.launched = true
		
		
		if power_ball_mode:
			new_ball.set_power_ball(true)
		if explosive_mode:
			new_ball.set_explosive_ball()
		
		
		new_ball.direction = -direction.rotated(Vector3.UP, deg_to_rad(angle))
		
		
		var current_speed = velocity.length()
		new_ball.SPEED = current_speed  
		new_ball.velocity = new_ball.direction * current_speed
		
		
		new_ball.current_rotation = current_rotation
		
		get_tree().root.add_child(new_ball)

extends CharacterBody3D

@export var SPEED: float = 15.0
@export var BOUNCE: float = 1.0
@export var attach_offset: Vector3 = Vector3(0, 0, -1)
@export var ROTATION_SPEED: float = 0.4  
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var audio_stream_player_2: AudioStreamPlayer = $AudioStreamPlayer2

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
	power_ball_mode = active
	

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

		var col = get_last_slide_collision()
		if col:
			var normal = col.get_normal()
			var collider = col.get_collider()

			# --- EXPLOSIVE BALL LOGIC ---
			if explosive_mode and collider.is_in_group("blocks"):
				audio_stream_player_2.play()
				audio_stream_player.play()
				# Eliminar todos los bloques cercanos
				var explosion_radius = 2.5
				var blocks = get_tree().get_nodes_in_group("blocks")
				for block in blocks:
					if block.global_transform.origin.distance_to(col.get_position()) <= explosion_radius:
						block.queue_free()
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
					audio_stream_player_2.play()
					# Rebote NORMAL con paleta
					var local_hit = col.get_position() - collider.global_transform.origin
					var pad_shape = collider.get_node("CollisionShape3D").shape
					var half_width = pad_shape.extents.x
					var factor = clamp(local_hit.x / half_width, -1, 1)
					direction.x = factor
					direction.z = -abs(direction.z)
					direction = direction.normalized()
			
			else:
				audio_stream_player_2.play()
				# Rebote con otros objetos (paredes, etc)
				direction = direction.bounce(col.get_normal()) * BOUNCE
				direction = direction.normalized()


var explosive_mode: bool = false

func set_explosive_ball() -> void:
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
	
	
func spawn_extra_balls():
	var angles = [30, -30]
	var ball_scene = load("res://scenes/ball.tscn")
	
	for angle in angles:
		var new_ball = ball_scene.instantiate()
		new_ball.add_to_group("ball")
		
		# Heredar configuraciones de colisión
		new_ball.collision_layer = collision_layer  # Capa 'balls' (1)
		new_ball.collision_mask = collision_mask    # Máscara original (blocks + player)
		
		new_ball.global_transform = global_transform
		new_ball.direction = -direction.rotated(Vector3.UP, deg_to_rad(angle))
		new_ball.launched = true
		new_ball.velocity = new_ball.direction * SPEED
		
		get_tree().root.add_child(new_ball)

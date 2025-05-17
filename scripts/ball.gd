extends CharacterBody3D

@export var SPEED: float = 15.0
@export var BOUNCE: float = 1.0
@export var attach_offset: Vector3 = Vector3(0, 0, -1)

var launched: bool = false
var direction: Vector3 = Vector3(0, 0, 1)

var power_ball_mode: bool = false


func _ready() -> void:
	add_to_group("ball")
	velocity = Vector3.ZERO

func set_power_ball(active: bool) -> void:
	power_ball_mode = active
	

func _physics_process(delta: float) -> void:
	if not launched:
		
		#lock to player
		var paddle_transform = get_parent().global_transform
		global_transform.origin = paddle_transform.origin + attach_offset

		
		if Input.is_action_just_pressed("ui_accept"):
			#unlock from player
			var was_global = global_transform
			var root = get_tree().get_current_scene()
			get_parent().remove_child(self)
			root.add_child(self)
			global_transform = was_global
			launched = true

			var move_input = Input.get_axis("ui_left", "ui_right")
			if move_input < 0:
				direction = Vector3(-1, 0, -1)
			elif move_input > 0:
				direction = Vector3( 1, 0, -1)
			else:
				direction = Vector3( 0, 0, -1)
			direction = direction.normalized()
			velocity  = direction * SPEED


	else:
		direction = direction.normalized()
		velocity = direction * SPEED
		move_and_slide()

		var col = get_last_slide_collision()
		if col:
			var collider = col.get_collider()
			if power_ball_mode and collider.is_in_group("blocks"):
				# No rebotamos, seguimos en la misma dirección
				pass
			elif collider.is_in_group("Player"):
				# bounce against the player (controled by code)
				var local_hit = col.get_position() - collider.global_transform.origin
				var pad_shape = collider.get_node("CollisionShape3D").shape
				var half_width = pad_shape.extents.x
				var factor = clamp(local_hit.x / half_width, -1, 1)

				direction.x = factor
				direction.z = -abs(direction.z)
				direction = direction.normalized()
			else:
				# bounce controled by physics
				direction = direction.bounce(col.get_normal()) * BOUNCE
				direction = direction.normalized()

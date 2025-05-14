extends CharacterBody3D

@export var SPEED: float = 20.0
@export var attach_offset: Vector3 = Vector3(0, 0, -1.5)

var launched: bool = false
var direction: Vector3 = Vector3(0, 0, 1)

func _ready() -> void:
	add_to_group("ball")
	velocity = Vector3.ZERO

func _physics_process(delta: float) -> void:
	if not launched:
		# — attach to paddle until launch —
		var paddle_tf = get_parent().global_transform
		global_transform.origin = paddle_tf.origin + attach_offset

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

		# 4. Read collisions and update 'direction' for next frame
		var col = get_last_slide_collision()
		if col:
			var normal = col.get_normal()
			var collider = col.get_collider()
			if collider.is_in_group("Player"):
				# Player‐controlled bounce
				var local_hit = col.get_position() - collider.global_transform.origin
				var half_w = collider.get_node("CollisionShape3D").shape.extents.x
				var factor = clamp(local_hit.x / half_w, -1, 1)
				direction = Vector3(factor, 0, -abs(direction.z)).normalized()
			else:
				# Perfect elastic bounce (no speed change)
				direction = direction.bounce(normal).normalized()

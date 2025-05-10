extends CharacterBody3D

@export var SPEED: float = 20.0
@export var BOUNCE: float = 1.0

# Direction the ball is moving initialy
var direction: Vector3 = Vector3(0.5, 0, 1)

func _ready() -> void:
	# Initialize the built‑in velocity
	velocity = direction * SPEED
	add_to_group("ball")

func _physics_process(delta: float) -> void:
	direction = direction.normalized()
	velocity = direction * SPEED
	move_and_slide()

	var col = get_last_slide_collision()
	if col:
		var collider = col.get_collider()
		if collider.is_in_group("Player"): 
			print("Player")
			var local_hit_pos = col.get_position() - collider.global_transform.origin
			var paddle_width = collider.get_node("CollisionShape3D").shape.extents.x

			var factor = clamp(local_hit_pos.x / paddle_width, -1, 1)

			direction.x = factor
			direction.z = -abs(direction.z)

			direction = direction.normalized()
		else:
			direction = direction.bounce(col.get_normal()) * BOUNCE

		velocity = direction * SPEED

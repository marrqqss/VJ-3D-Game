extends RigidBody3D

@onready var detector := $HitDetector

func _ready() -> void:
	add_to_group("blocks")

	gravity_scale = 1

	# Connect the Area3D signal
	detector.body_entered.connect(Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("ball"):
		return
	
	print("ball")

	var my_pos: Vector3 = global_transform.origin
	queue_free()

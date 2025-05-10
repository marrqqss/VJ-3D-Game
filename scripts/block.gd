# Block.gd
extends RigidBody3D

const ABOVE_Y_THRESHOLD := 0.1
const COLUMN_RADIUS := 0.5

@onready var detector := $HitDetector

func _ready() -> void:
	add_to_group("blocks")

	# Start “frozen”: no gravity, sleeping
	gravity_scale = 1

	# Connect the Area3D signal
	detector.body_entered.connect(Callable(self, "_on_body_entered"))


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("ball"):
		return

	print("ball")  # you should see this now

	var my_pos: Vector3 = global_transform.origin
	queue_free()

	# Unfreeze any blocks sitting directly above
	for blk in get_tree().get_nodes_in_group("blocks"):
		if not (blk and blk is RigidBody3D):
			continue
		var bpos: Vector3 = blk.global_transform.origin
		if bpos.y > my_pos.y + ABOVE_Y_THRESHOLD \
		and bpos.distance_to(Vector3(my_pos.x, bpos.y, my_pos.z)) < COLUMN_RADIUS:
			blk.gravity_scale = 1
			blk.sleeping = false

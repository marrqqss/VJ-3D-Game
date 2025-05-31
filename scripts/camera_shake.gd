extends Camera3D

var shake_amount = 0.0
var shake_decay = 5.0
var shake_strength = 0.25

var original_position: Vector3

func _ready():
	original_position = global_transform.origin

func _process(delta):
	if shake_amount > 0.01:
		var shake_offset = Vector3(
			(randf() - 0.5) * 2.0,
			(randf() - 0.5) * 2.0,
			(randf() - 0.5) * 2.0
		) * shake_strength * shake_amount
		global_transform.origin = original_position + shake_offset
		shake_amount = lerp(shake_amount, 0.0, shake_decay * delta)
	

func trigger_shake(intensity: float = 1.0):
	print("SHAKE")
	shake_amount = intensity

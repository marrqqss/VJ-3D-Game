extends Node3D

@onready var camera_pivot: Node3D = $CameraPivot
@onready var player: Node = $Player

var rotation_speed: float = 50
var drop_height: float   = 15

func _ready() -> void:
	player.set_process(false)
	player.set_physics_process(false)

	var start_angle = camera_pivot.rotation_degrees.y
	var start_y = camera_pivot.position.y

	camera_pivot.position.y = start_y - drop_height
	_animate_intro(start_angle, start_y)

func _animate_intro(start_angle: float, start_y: float) -> void:
	var target_angle = start_angle + 360.0
	var duration     = 360.0 / rotation_speed

	var tween = create_tween()
	# rotate and move in parallel
	tween.tween_property(camera_pivot, "rotation_degrees:y", target_angle, duration) \
			.set_trans(Tween.TRANS_LINEAR) \
			.set_ease(Tween.EASE_IN_OUT)
	tween.parallel()
	tween.tween_property(camera_pivot, "position:y", start_y, duration) \
			.set_trans(Tween.TRANS_LINEAR) \
			.set_ease(Tween.EASE_IN_OUT)

	await tween.finished
	camera_pivot.rotation_degrees.y = fmod(start_angle, 360.0)
	camera_pivot.position.y          = start_y
	player.set_process(true)
	player.set_physics_process(true)

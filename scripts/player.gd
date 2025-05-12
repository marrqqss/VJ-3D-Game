extends CharacterBody3D

# Export for inspector
@export var SPEED: float = 10.0

# Remember original scale so we can restore it
var _orig_scale: Vector3

# Reference to the Timer node
@onready var _expand_paddle_timer = $expand_paddle_timer

func _ready() -> void:
	# Cache the starting scale
	_orig_scale = scale
	# Connect the timer’s timeout
	_expand_paddle_timer.connect("timeout", Callable(self, "_on_powerup_timeout"))


func _physics_process(delta: float) -> void:
	if not _expand_paddle_timer.is_stopped():
		print(_expand_paddle_timer.time_left)
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()


# Called by the Powerup when “expand_paddle” is picked up
func expand_paddle() -> void:
	# 1) immediately bump up the scale
	scale.x = _orig_scale.x * 1.5

	# 2) restart the timer
	if _expand_paddle_timer.is_stopped() == false:
		_expand_paddle_timer.stop()
	_expand_paddle_timer.start(20.0)


# Timer callback: restore scale
func _on_powerup_timeout() -> void:
	scale = _orig_scale

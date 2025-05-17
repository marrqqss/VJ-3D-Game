extends CharacterBody3D

# Export for inspector
@export var SPEED: float = 10.0

# Remember original scale so we can restore it
var _orig_scale: Vector3

# Reference to the Timer node
@onready var _expand_paddle_timer = $expand_paddle_timer

var _power_ball_active: bool = false
@onready var _power_ball_timer = $power_ball_timer

func _ready() -> void:
	# Cache the starting scale
	_orig_scale = scale
	# Connect the timer’s timeout
	_expand_paddle_timer.connect("timeout", Callable(self, "_on_expand_paddle_timeout"))
	_power_ball_timer.connect("timeout", Callable(self, "_on_power_ball_timeout"))

func _input(event):
	if event.is_action_pressed("test_expand_paddle"):
		expand_paddle()
	if event.is_action_pressed("test_power_ball"):
		power_ball()


func _physics_process(delta: float) -> void:
	if not _power_ball_timer.is_stopped():
		print(_power_ball_timer.time_left)
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
func _on_expand_paddle_timeout() -> void:
	scale = _orig_scale
	
func power_ball() -> void:
	# Activar el powerup
	_power_ball_active = true
	
	# Indicarle a la bola que está en modo power_ball
	var balls = get_tree().get_nodes_in_group("ball")
	for ball in balls:
		if ball.has_method("set_power_ball"):
			ball.set_power_ball(true)
	
	# Iniciar el temporizador
	if _power_ball_timer.is_stopped() == false:
		_power_ball_timer.stop()
	_power_ball_timer.start(10.0)  # 10 segundos de duración	
	
func _on_power_ball_timeout() -> void:
	_power_ball_active = false
	
	# Desactivar el modo power_ball en todas las bolas
	var balls = get_tree().get_nodes_in_group("ball")
	for ball in balls:
		if ball.has_method("set_power_ball"):
			ball.set_power_ball(false)

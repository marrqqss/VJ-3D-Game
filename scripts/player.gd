extends CharacterBody3D

# Export for inspector
@export var SPEED: float = 10.0

var _orig_scale: Vector3
var _current_scale_factor: float = 1.0

# Reference to the Timer node
var _power_ball_active: bool = false
@onready var _power_ball_timer = $power_ball_timer

func _ready() -> void:
	# Cache the starting scale
	_orig_scale = scale
	# Connect the timer’s timeout
	_power_ball_timer.connect("timeout", Callable(self, "_on_power_ball_timeout"))

func _input(event):
	if event.is_action_pressed("test_expand_paddle"):
		expand_paddle()
	if event.is_action_pressed("test_power_ball"):
		power_ball()
	if event.is_action_pressed("test_reduce_paddle"):
		reduce_paddle()


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
	_current_scale_factor *= 1.2  # Aumenta 20% cada vez
	scale.x = _orig_scale.x * _current_scale_factor
	
	
func reduce_paddle() -> void:
	_current_scale_factor *= 0.8  # Reduce 20% cada vez
	scale.x = _orig_scale.x * _current_scale_factor

	
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

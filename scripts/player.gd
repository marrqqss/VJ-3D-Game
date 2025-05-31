extends CharacterBody3D

# Export for inspector
@export var SPEED: float = 10.0

var _orig_scale: Vector3
var _current_scale_factor: float = 1.0

# Reference to the Timer node
var _power_ball_active: bool = false
var magnet_active: bool = false

func _ready() -> void:
	# Cache the starting scale
	_orig_scale = scale

func _input(event):
	if event.is_action_pressed("test_expand_paddle"):
		expand_paddle()
	if event.is_action_pressed("test_power_ball"):
		power_ball()
	if event.is_action_pressed("test_reduce_paddle"):
		reduce_paddle()
	if event.is_action_pressed("test_magnet"):
		activate_magnet()
	if event.is_action_pressed("test_extra_balls"):
		var balls = get_tree().get_nodes_in_group("ball")
		for ball in balls:
			ball.spawn_extra_balls()
	if event.is_action_pressed("test_speed_ball"):
		speed_ball()
	if event.is_action_pressed("test_slow_ball"):
		slow_ball()
	if event.is_action_pressed("test_normal_ball"):
		normal_ball()
	if event.is_action_pressed("test_explosive_ball"):
		explosive_ball()


func _physics_process(delta: float) -> void:
	# Movimiento SIEMPRE activo (no depende de la bola)
	var direction := Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * SPEED
	move_and_slide()
	
	# Lógica de relanzamiento
	if Input.is_action_just_pressed("ui_accept"):
		var balls = get_tree().get_nodes_in_group("ball")
		for ball in balls:
			if ball.is_attached_to_paddle:
				ball.launch_from_paddle()

# TEST: Explosive Ball
func explosive_ball() -> void:
	var balls = get_tree().get_nodes_in_group("ball")
	for ball in balls:
		if ball.has_method("set_explosive_ball"):
			ball.set_explosive_ball()

# Called by the Powerup when “expand_paddle” is picked up
func expand_paddle() -> void:
	_current_scale_factor *= 1.2  # Aumenta 20% cada vez
	scale.x = _orig_scale.x * _current_scale_factor
	
	
func reduce_paddle() -> void:
	_current_scale_factor *= 0.8  # Reduce 20% cada vez
	scale.x = _orig_scale.x * _current_scale_factor

	
func power_ball() -> void:
	# Activar el powerup permanentemente
	_power_ball_active = true
	# Indicarle a la bola que está en modo power_ball
	var balls = get_tree().get_nodes_in_group("ball")
	for ball in balls:
		if ball.has_method("set_power_ball"):
			ball.set_power_ball(true)

# NORMAL BALL POWER-UP
func normal_ball() -> void:
	_power_ball_active = false
	# Desactivar el modo power_ball en todas las bolas
	var balls = get_tree().get_nodes_in_group("ball")
	for ball in balls:
		if ball.has_method("set_power_ball"):
			ball.set_power_ball(false)
	

func activate_magnet() -> void:
	magnet_active = true

func speed_ball() -> void:
	var balls = get_tree().get_nodes_in_group("ball")
	for ball in balls:
		ball.SPEED *= 1.2 # Aumenta velocidad 20%

func slow_ball() -> void:
	var balls = get_tree().get_nodes_in_group("ball")
	for ball in balls:
		ball.SPEED *= 0.8 # Reduce velocidad 20%

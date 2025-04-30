extends RigidBody3D

const SPEED = 20

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#the velocity of a rigidbody can be defined with the variable "linear_velocity"
	linear_velocity = Vector3(0,0,1) * SPEED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if linear_velocity.length() != SPEED:
		linear_velocity = linear_velocity.normalized() * SPEED

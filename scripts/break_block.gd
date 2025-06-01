extends Node3D

@onready var debris: GPUParticles3D = $Debris

func break_block_particles(color: Color) -> void:
	var mat := debris.process_material.duplicate()
	if mat is ParticleProcessMaterial:
		mat.color = color
		debris.process_material = mat
	debris.restart()
	debris.emitting = true
	await get_tree().create_timer(2.0).timeout
	queue_free()

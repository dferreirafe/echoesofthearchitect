extends ColorRect


@onready var noise :NoiseTexture2D = material.get_shader_parameter("noise_tex")


func _process(delta: float) -> void:
	if visible == true:
		noise.noise.offset.y += 64 * delta

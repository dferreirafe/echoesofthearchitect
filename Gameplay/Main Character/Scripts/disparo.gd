extends Area2D

# Referencia al marcador que indica la dirección hacia la cual se moverá el disparo.
@onready var marker_2d: Marker2D = $Marker2D

# Si es verdadero, el disparo se destruirá al colisionar con algo.
@export var destructible = true
# Si es verdadero, puede generar otro objeto (como puas) al explotar.
@export var generate = true

# Se ejecuta en cada frame de física.
func _physics_process(delta: float) -> void:
	# Calcula la dirección hacia el marcador.
	var dir = marker_2d.global_position - global_position
	# Normaliza el vector para obtener solo la dirección.
	dir = dir.normalized()
	# Aplica una velocidad de 750 píxeles por segundo en esa dirección.
	dir *= 750
	# Mueve el disparo según esa dirección y el tiempo delta.
	global_position += dir * delta

# Se llama automáticamente cuando el disparo colisiona con un cuerpo (otro Node2D con colisiones).
func _on_body_entered(body: Node2D) -> void:
	# Obtiene el nodo encargado de sacudir la cámara (si existe en el grupo "CameraGame").
	var g : CameraShake = get_tree().get_first_node_in_group("CameraGame")
	if g:
		# Ejecuta un efecto de sacudida con intensidad y duración definidas.
		g.Shake(25, 2, 0.05, 15)

	# Instancia una partícula de explosión de fuego y la añade al padre de este nodo.
	var c = preload("res://Assets/Particles/explosion_fire.tscn").instantiate()
	c.global_position = global_position
	get_parent().call_deferred("add_child", c)
	c.restart()

	# Instancia una partícula adicional de rocas y la añade.
	var d = preload("res://Assets/Particles/rocks_explosion.tscn").instantiate()
	d.global_position = global_position
	get_parent().call_deferred("add_child", d)
	d.restart()

	# Si el disparo es destructible, se evalúa si debe generar puas.
	if destructible == true:
		# Verifica si el jefe actual está en su etapa final y si está permitido generar puas.
		if get_tree().get_first_node_in_group("Boss").StageFinal == true and generate == true:
			# Instancia y añade el nodo de puas en la posición X actual.
			var M = preload("res://Gameplay/Main Character/Attacks/puas.tscn").instantiate()
			M.global_position.x = global_position.x
			get_parent().call_deferred("add_child", M)
		# El proyectil se elimina de la escena.
		queue_free()

	# Si el cuerpo con el que colisiona tiene un método llamado "Hit", se lo llama con 15 de daño.
	if body.has_method("Hit"):
		body.Hit(15)

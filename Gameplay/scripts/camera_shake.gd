class_name CameraShake
extends Camera2D

# Almacena el desplazamiento original de la cámara.
var Offset = Vector2()

# Referencia al tween activo para el efecto de sacudida.
var tween :Tween
# Nivel de prioridad actual del efecto de sacudida.
var prioridad := 0

func _ready():
	# Guarda el valor inicial del offset de la cámara.
	Offset = offset
	# Si no está en el grupo "CameraGame", lo agrega. Esto permite que otros nodos la encuentren.
	if !is_in_group("CameraGame"):
		add_to_group("CameraGame")

# Devuelve un vector aleatorio dentro del rango definido por la fuerza.
func GetOffset(force := 1.0):
	var x = randf_range(-force, force)
	var y = randf_range(-force, force)
	return Vector2(x,y)

# Inicia el efecto de sacudida de cámara.
# `force`: distancia que se mueve la cámara en cada sacudida.
# `shakes`: cuántas veces se sacude.
# `time`: duración de cada sacudida.
# `priority`: prioridad del efecto; sólo efectos con prioridad mayor pueden interrumpir otros.
func Shake(force :float, shakes : float, time : float, priority : int):
	# Si hay una sacudida en curso con igual o mayor prioridad, se ignora esta.
	if prioridad >= priority:
		return
	
	# Se guarda la nueva prioridad.
	prioridad = priority

	# Si ya existe un tween activo, se anula la referencia (aunque no se detiene explícitamente).
	if tween != null:
		tween = null
	
	# Crea un nuevo tween para animar la propiedad offset.
	tween = create_tween()
	
	var i = 0
	while i < shakes:
		# Aplica un nuevo offset aleatorio respecto al valor original.
		tween.tween_property(self, "offset", Offset + GetOffset(force), time)
		print("Shakes") # Solo para debug; muestra un mensaje cada vez que tiembla.
		i += 1

	# Regresa la cámara al offset original.
	tween.tween_property(self, "offset", Offset, time)

	# Reinicia la prioridad a 0 para permitir nuevas sacudidas.
	tween.tween_property(self, "prioridad", 0.0, 0)

	# Llama a ExitTween cuando el tween termina.
	tween.tween_callback(Callable(self, "ExitTween"))

# Limpia la referencia al tween cuando finaliza.
func ExitTween():
	tween = null

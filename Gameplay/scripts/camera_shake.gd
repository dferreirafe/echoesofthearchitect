class_name CameraShake
extends Camera2D


var Offset = Vector2()

var tween :Tween
var prioridad := 0

func _ready():
	Offset = offset
	if !is_in_group("CameraGame"):
		add_to_group("CameraGame")

func GetOffset(force := 1.0):
	var x = randf_range(-force, force)
	var y = randf_range(-force, force)
	return Vector2(x,y)


func Shake(force :float, shakes : float, time : float, priority : int):
	if prioridad >= priority:
		return
	
	prioridad = priority
	if tween != null:
		tween = null
	
	tween = create_tween()
#	var Offset = offset
	var i = 0
	while i < shakes:
		tween.tween_property(self, "offset", Offset + GetOffset(force), time)
		print("Shakes")
		i += 1
	tween.tween_property(self, "offset", Offset, time)
	tween.tween_property(self, "prioridad", 0.0, 0)
	tween.tween_callback(Callable(self, "ExitTween"))


func ExitTween():
	tween = null

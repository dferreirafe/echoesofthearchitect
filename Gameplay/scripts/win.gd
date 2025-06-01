extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(0.15).timeout
	get_tree().paused = true

func start():
	return
	get_tree().paused = false


func _restart():
	get_tree().reload_current_scene()

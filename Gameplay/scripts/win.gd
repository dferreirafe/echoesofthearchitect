extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().paused = true

func start():
	get_tree().paused = false


func _restart():
	get_tree().reload_current_scene()

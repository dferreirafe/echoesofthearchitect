extends Area2D


func _ready() -> void:
	var t = create_tween().set_trans(Tween.TRANS_CUBIC)
	var t2 = create_tween().set_trans(Tween.TRANS_CUBIC)
	t.tween_property(self, "position:y", 607, 0.5)
	t2.tween_callback(shake).set_delay(0.38)
	t.tween_property(self, "modulate:a", 0.0, 0.2).set_delay(0.35)
	t.tween_callback(queue_free)


func shake():
	var g : CameraShake = get_tree().get_first_node_in_group("CameraGame")
	if g:
		g.Shake(35, 4, 0.05, 25)

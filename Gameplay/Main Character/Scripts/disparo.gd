extends Area2D

@onready var marker_2d: Marker2D = $Marker2D

func _physics_process(delta: float) -> void:
	var dir = marker_2d.global_position - global_position
	dir = dir.normalized()
	dir *= 750
	global_position += dir * delta


func _on_body_entered(body: Node2D) -> void:
	var g : CameraShake = get_tree().get_first_node_in_group("CameraGame")
	if g:
		g.Shake(25, 2, 0.05, 15)
	var c = preload("res://Assets/Particles/explosion_fire.tscn").instantiate()
	c.global_position = global_position
	get_parent().call_deferred("add_child", c)
	c.restart()
	var d = preload("res://Assets/Particles/rocks_explosion.tscn").instantiate()
	d.global_position = global_position
	get_parent().call_deferred("add_child", d)
	d.restart()
	queue_free()
	if body.has_method("Hit"):
		body.Hit(15)

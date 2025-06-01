extends CanvasLayer

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		Global.Stage = 0
		Global.Final = ""
		Global.momento = ""
		Global.quieto = false
		Global.hero = {
		"health" : 25,
		"learning" : [],
		"force" : 1.5,
}
		get_tree().paused = false
		get_tree().change_scene_to_file("res://Gameplay/Scenes/MenuPrincipal.tscn")
		


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Gameplay/Scenes/MenuPrincipal.tscn")
	
	Global.Stage = 0
	Global.Final = ""
	Global.momento = ""
	Global.quieto = false
	Global.hero = {
	"health" : 25,
	"learning" : [],
	"force" : 1.5,
}

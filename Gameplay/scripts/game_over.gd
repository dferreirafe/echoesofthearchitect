extends CanvasLayer

func _ready() -> void:
	get_tree().paused = true


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	Global.hero = {
	"health" : 150,
	"learning" : [],
	"force" : 3.5,
}
	get_tree().reload_current_scene()

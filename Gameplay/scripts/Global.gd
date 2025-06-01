extends Node


var hero = {
	"health" : 25,
	"learning" : [],
	"force" : 1.0,
}

var Stage = 0
var Final = ""
var momento = ""
var quieto = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if Final == "A":
		Final = ""
		get_tree().paused = true
		var c = preload("res://Gameplay/Scenes/Finales/FinalA.tscn").instantiate()
		get_tree().get_first_node_in_group("Level").call_deferred("add_child", c)
	elif Final == "B":
		Final = ""
		get_tree().paused = true
		var c = preload("res://Gameplay/Scenes/Finales/Final.tscn").instantiate()
		get_tree().get_first_node_in_group("Level").call_deferred("add_child", c)
	elif Final == "C":
		Final = ""
		get_tree().paused = true
		var c = preload("res://Gameplay/Scenes/Finales/Final.tscn").instantiate()
		get_tree().get_first_node_in_group("Level").call_deferred("add_child", c)
	elif Final == "D":
		Final = ""
		get_tree().paused = true
		var c = preload("res://Gameplay/Scenes/Finales/Final.tscn").instantiate()
		get_tree().get_first_node_in_group("Level").call_deferred("add_child", c)

extends Control

@onready var sprites = [
	$AnimatedSprite2D3,
	$AnimatedSprite2D4,
	$AnimatedSprite2D5,
	$AnimatedSprite2D6,
	$AnimatedSprite2D7
]

func _ready():
	var escena_actual = get_tree().current_scene
	if escena_actual and escena_actual.scene_file_path.ends_with("MenuPrincipal.tscn"):
		print("Estamos en el menú principal")
		randomize()
		var elegido = sprites[randi() % sprites.size()]
		for sprite in sprites:
			sprite.visible = false
			sprite.stop()
		elegido.visible = true
		elegido.play()
	else:
		print("No es el menú principal")



func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Test.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_controles_pressed() -> void:
	get_tree().change_scene_to_file("res://Gameplay/Scenes/Controls.tscn")


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Gameplay/Scenes/MenuPrincipal.tscn")

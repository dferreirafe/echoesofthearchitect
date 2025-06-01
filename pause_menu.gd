extends CanvasLayer

@onready var boton_continuar = $Panel/Continuar
@onready var boton_salir = $Panel/Menu
@onready var boton_boton = $Panel/Button
@onready var panel = $Panel

func _ready():
	panel.anchor_left = 0
	panel.anchor_right = 1
	panel.anchor_top = 0
	panel.anchor_bottom = 1

	panel.offset_left = 0
	panel.offset_right = 0
	panel.offset_top = 0
	panel.offset_bottom = 0
	process_mode = Node.PROCESS_MODE_ALWAYS
	$Panel/Continuar.process_mode = Node.PROCESS_MODE_ALWAYS
	$Panel/Menu.process_mode = Node.PROCESS_MODE_ALWAYS
	$Panel/Continuar.pressed.connect(_on_continuar_pressed)
	$Panel/Menu.pressed.connect(_on_menu_pressed)

	$Panel/Continuar.mouse_entered.connect(func(): print("Cursor sobre botón Continuar"))
	
	visible = false
	print("PauseManager listo")
	await get_tree().process_frame
	boton_continuar.pressed.connect(_on_continuar_pressed)
	boton_salir.pressed.connect(_on_menu_pressed)

	

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			get_tree().paused = false
			print("▶ Reanudado")
			visible = false
		else:
			get_tree().paused = true
			print("⏸ Pausado")
			visible = true

func _on_continuar_pressed() -> void:
	get_tree().paused = false
	visible = false
	print("▶ Reanudado")


func _on_menu_pressed() -> void:
	get_tree().paused = false
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://Gameplay/Scenes/MenuPrincipal.tscn")

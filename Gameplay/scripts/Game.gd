extends Node2D


signal fire_ball 

signal manos 

@onready var pause_menu = $PauseMenu

var ataques = []

func _ready() -> void:
	if Global.Stage == 0:
		var c = load("res://Dialogos/dialogue.dialogue")
		var scene = "res://addons/dialogue_manager/example_balloon/example_balloon.tscn"
		DialogueManager.show_dialogue_balloon_scene(load(scene),c, "start")
		await get_tree().process_frame
		get_tree().get_first_node_in_group("Dialogo").tree_exited.connect(start)
		#await get_tree().create_timer(0.1).timeout
		#get_tree().paused = true
		print (Global.Stage)
		
	else:
		var c = load("res://Dialogos/dialogue.dialogue")
		var scene = "res://addons/dialogue_manager/example_balloon/example_balloon.tscn"
		DialogueManager.show_dialogue_balloon_scene(load(scene),c, "dialogo_stage_0" + str(Global.Stage) + str(Global.Final))
		await get_tree().process_frame
		get_tree().get_first_node_in_group("Dialogo").tree_exited.connect(start)
		print (Global.Stage)

func start():
	get_tree().paused = false

func game_over():
	get_tree().paused = true
	await get_tree().create_timer(0.5).timeout
	var c = load("res://Dialogos/dialogue.dialogue")
	var scene = "res://addons/dialogue_manager/example_balloon/balloon_st2.tscn"
	DialogueManager.show_dialogue_balloon_scene(load(scene),c, "dialogo_derrota")


func restart():
	Global.hero = {
	"health" : 150,
	"learning" : [],
	"force" : 3.5,
}
	get_tree().reload_current_scene()

func Stage2():
	$CanvasLayer2/AnimationPlayer.play("anim")
	var boss = $Boss
	var c = preload("res://bossStage02.tscn").instantiate()
	call_deferred("add_child", c)
	c.set_deferred("global_position", boss.global_position)
	c.set_deferred("Health", boss.Health)
	$Hero.target = c
	c.set_deferred("current_state", boss.STATES.MOVEMENT)
	$PostProcess.configuration.ScreenShake = true
	$Parallax2D/BackgroundPlaceHolder2.texture = load("res://Assets/Textures/Background2.png")

func UpdateIA():
	AddIa("Attack", "Golpe")
	AddIa("Manos", "ManosDemon")
	AddIa("fire_ball", "FireBall")
	AddIa("Puas", "Golpe")
	AddIa("MultiFireball", "CorteDobleSalto")
	AddIa("MultiFireball", "Corte")
	AddIa("Attack", "Golpe")
	
	if ataques.has("Puas") and Global.hero["learning"].has("Dash") and !Global.hero["learning"].has("DashPuas"):
		Global.hero["learning"].append("DashPuas")
	if ataques.has("Attack") and Global.hero["learning"].has("Golpe") and !Global.hero["learning"].has("Dash"):
		Global.hero["learning"].append("Dash")
	
		

func AddIa(ataque, estrategia):
	if ataques.has(ataque) and !Global.hero["learning"].has(estrategia):
		Global.hero["learning"].append(estrategia)

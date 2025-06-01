extends CharacterBody2D


signal UsePuas

@onready var Animations: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $Body/AnimatedSprite2D
@onready var marker_puas: Marker2D = $Body/marker_puas
@onready var markers_disparos: Node2D = $Body/markersDisparos
@onready var progress_bar: ProgressBar = $CanvasLayer/ProgressBar

@onready var body: Node2D = $Body

@export var speed = 500.0
@export var jump_force = -1200.0

var Health = 500.0

enum STATES {
	MOVEMENT, ATTACK, HITTING
}

var current_state = STATES.MOVEMENT

func _ready() -> void:
	progress_bar.max_value = Health
	for i in markers_disparos.get_children():
		i.hide()

func _physics_process(delta: float) -> void:
	
	progress_bar.value = Health
	match current_state:
		STATES.MOVEMENT:
			if not is_on_floor():
				Animations.play("Fall")
				velocity += get_gravity() * delta * 3.5

			if Input.is_action_just_pressed("ui_accept") and is_on_floor():
				velocity.y = jump_force

			var direction := Input.get_axis("ui_left", "ui_right")
			if direction:
				velocity.x = direction * speed
				body.scale.x = direction
				if is_on_floor():
					Animations.play("Run")
			else:
				velocity.x = move_toward(velocity.x, 0, speed)
				if is_on_floor():
					Animations.play("Idle")
			
			if Input.is_action_just_pressed("ui_attack_normal"):
				if is_on_floor():
					var g : CameraShake = get_tree().get_first_node_in_group("CameraGame")
					if g:
						g.Shake(6, 1, 0.05, 5)
					current_state = STATES.ATTACK
					Animations.play("Attack1")
				else:
					velocity.y = 5000
			if Input.is_action_just_pressed("ui_attack_especial"):
				current_state = STATES.ATTACK
				if is_on_floor():
					Animations.play("Attack2")
					emit_signal("UsePuas")
				else:
					Animations.play("Attack2", -1 , 2.0)
				
		STATES.ATTACK:
			velocity.x = 0
			velocity.y = 0
			
		STATES.HITTING:
			velocity.x = 0.0
	move_and_slide()
	$Body/AnimatedSprite2D2.animation = animated_sprite_2d.animation
	$Body/AnimatedSprite2D2.frame = animated_sprite_2d.frame


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Jump":
		Animations.play("Fall")
	elif anim_name in ["Attack1", "Attack2"]:
		current_state = STATES.MOVEMENT

func Special_Attack():
	if is_on_floor():
		var c = preload("res://Gameplay/Main Character/Attacks/puas.tscn").instantiate()
		c.global_position.x = marker_puas.global_position.x
		get_parent().call_deferred("add_child", c)
	else:
		for i in markers_disparos.get_children():
			var c = preload("res://Gameplay/Main Character/Attacks/disparo.tscn").instantiate()
			c.global_position = i.global_position
			c.global_rotation_degrees = i.global_rotation_degrees
			get_parent().call_deferred("add_child", c)

func Hit(force := 5.0):
	Health -= force
	$Body/AreaAttack/CollisionShape2D.set_deferred("disabled", true)
	$HitAnim.play("Hit")
	current_state = STATES.HITTING
	var c = preload("res://Assets/Particles/particles_damage.tscn").instantiate()
	c.global_position = global_position
	get_parent().call_deferred("add_child", c)
	c.restart()
	await get_tree().create_timer(0.15).timeout
	current_state = STATES.MOVEMENT
	if Health <= 0:
		var game_over = preload("res://Gameplay/Scenes/game_over.tscn").instantiate()
		get_parent().call_deferred("add_child", game_over)

func attack_hero(body: Node2D) -> void:
	if body.has_method("Hit"):
		body.Hit()

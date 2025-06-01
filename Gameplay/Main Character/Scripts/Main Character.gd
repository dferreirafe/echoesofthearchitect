extends CharacterBody2D

# Señales personalizadas para ataques
signal UsePuas
signal UseGolpe

# Referencias a nodos dentro de la escena
@onready var Animations: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $Body/AnimatedSprite2D
@onready var marker_puas: Marker2D = $Body/marker_puas
@onready var markers_disparos: Node2D = $Body/markersDisparos
@onready var progress_bar: ProgressBar = $CanvasLayer/ProgressBar
@onready var sombra: Sprite2D = $Sombra
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var body: Node2D = $Body


# Variables exportables para configurar velocidad y salto desde el editor
@export var speed = 500.0
@export var jump_force = -1200.0
@export var StageFinal = false  # Indica si está en la etapa final del jefe

# Vida del personaje
var Health = 500.0

# Definición de los posibles estados del personaje
enum STATES {
	MOVEMENT, ATTACK, HITTING
}

# Estado actual del personaje
var current_state = STATES.MOVEMENT

# Función que se ejecuta al inicializar la escena
func _ready() -> void:
	add_to_group("Boss")  # Se añade a un grupo para facilitar su manejo
	progress_bar.max_value = Health  # Se define el valor máximo de la barra de vida
	for i in markers_disparos.get_children():
		i.hide()  # Se ocultan los marcadores de disparo inicialmente
	


# Función de física que se ejecuta en cada frame
func _physics_process(delta: float) -> void:
	progress_bar.value = Health  # Actualiza el valor de la barra de vida
	
	match current_state:
		STATES.MOVEMENT:
			# Si está en el aire, aplica gravedad
			if not is_on_floor():
				Animations.play("Fall")
				velocity += get_gravity() * delta * 3.5

			# Salto si está en el suelo y se presiona el botón de aceptar
			if Input.is_action_just_pressed("ui_accept") and is_on_floor():
				velocity.y = jump_force

			# Movimiento lateral con animación
			var direction := Input.get_axis("ui_left", "ui_right")
			if direction:
				velocity.x = direction * speed
				body.scale.x = direction  # Cambia la dirección del sprite
				if is_on_floor():
					Animations.play("Run")
			else:
				velocity.x = move_toward(velocity.x, 0, speed)
				if is_on_floor():
					Animations.play("Idle")
			
			# Ataque normal
			if Input.is_action_just_pressed("ui_attack_normal"):
				if is_on_floor():
					get_parent().ataques.append("Attack")
					emit_signal("UseGolpe")
					var g : CameraShake = get_tree().get_first_node_in_group("CameraGame")
					if g:
						g.Shake(6, 1, 0.05, 5)
					current_state = STATES.ATTACK
					Animations.play("Attack1")
				else:
					velocity.y = 5000  # Empuja hacia abajo si está en el aire

			# Ataque especial
			if Input.is_action_just_pressed("ui_attack_especial"):
				current_state = STATES.ATTACK
				if is_on_floor():
					Animations.play("Attack2")
					emit_signal("UsePuas")
				else:
					Animations.play("Attack2", -1 , 2.0)
				
		STATES.ATTACK:
			# Se detiene completamente durante el ataque
			velocity.x = 0
			velocity.y = 0
			
		STATES.HITTING:
			# No se mueve durante la animación de daño
			velocity.x = 0.0

	move_and_slide()  # Aplica el movimiento
	$Body/AnimatedSprite2D2.animation = animated_sprite_2d.animation
	$Body/AnimatedSprite2D2.frame = animated_sprite_2d.frame

	# Posiciona la sombra en el punto de colisión detectado por el raycast
	if ray_cast_2d.is_colliding():
		sombra.global_position = ray_cast_2d.get_collision_point()

# Se ejecuta al finalizar una animación
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Jump":
		Animations.play("Fall")
	elif anim_name in ["Attack1", "Attack2"]:
		current_state = STATES.MOVEMENT

# Ataque especial del jefe
func Special_Attack():
	if StageFinal == true:
		if is_on_floor():
			$FireBall.play(0.06)
			get_parent().emit_signal("fire_ball")
			get_parent().ataques.append("FireBall")
			var c = preload("res://Gameplay/Main Character/Attacks/fire_ball.tscn").instantiate()
			c.global_position = $Body/MarkerFireBall.global_position
			c.scale.x = body.scale.x
			get_parent().call_deferred("add_child", c)
		else:
			$FireBall.play(0.06)
			get_parent().ataques.append("MultiFireball")
			for i in markers_disparos.get_children():
				var c = preload("res://Gameplay/Main Character/Attacks/disparo.tscn").instantiate()
				c.global_position = i.global_position
				c.global_rotation_degrees = i.global_rotation_degrees
				get_parent().call_deferred("add_child", c)
		return
	
	# Si no es etapa final
	if is_on_floor():
		get_parent().ataques.append("Puas")
		var c = preload("res://Gameplay/Main Character/Attacks/puas.tscn").instantiate()
		c.global_position.x = marker_puas.global_position.x
		get_parent().call_deferred("add_child", c)
	else:
		get_parent().ataques.append("MultiFireball")
		$FireBall.play(0.06)
		for i in markers_disparos.get_children():
			var c = preload("res://Gameplay/Main Character/Attacks/disparo.tscn").instantiate()
			c.global_position = i.global_position
			c.global_rotation_degrees = i.global_rotation_degrees
			get_parent().call_deferred("add_child", c)

# Reproduce las partículas de muerte con retrasos
func particlesDeath():
	var delay = 0.0
	for i in $ParticlesDeath.get_children():
		await get_tree().create_timer(delay).timeout
		i.restart()
		delay += 0.025

# Función llamada al recibir daño
func Hit(force := 5.0):
	$Hit.play()
	if StageFinal == true:
		force *= 0.5  # En etapa final el daño es reducido
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

	# Transición a segunda etapa o fin del jefe
	if Health <= 150 and StageFinal == false:
		get_parent().Stage2()
		get_tree().process_frame
		queue_free()
		return
	
	if Health <= 0:
		particlesDeath()
		get_parent().game_over()

# Ataca al héroe si tiene la función Hit()
func attack_hero(body: Node2D) -> void:
	if body.has_method("Hit"):
		body.Hit()

# Ejecuta ataque "Manos" con tres instancias
func Manos():
	get_parent().ataques.append("Manos")
	get_parent().emit_signal("manos")
	var c = preload("res://Gameplay/Main Character/Attacks/Mano.tscn").instantiate()
	c.global_position = $"../Hero".global_position
	c.position.y += 30
	get_parent().call_deferred("add_child", c)
	
	var d = preload("res://Gameplay/Main Character/Attacks/Mano.tscn").instantiate()
	d.global_position = $"../Hero".global_position
	d.position.y += 30
	d.position.x += 150
	get_parent().call_deferred("add_child", d)
	
	var p = preload("res://Gameplay/Main Character/Attacks/Mano.tscn").instantiate()
	p.global_position = $"../Hero".global_position
	p.position.y += 30
	p.position.x -= 150
	get_parent().call_deferred("add_child", p)

	

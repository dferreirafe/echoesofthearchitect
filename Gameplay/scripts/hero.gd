class_name Hero
extends CharacterBody2D


@onready var body: Node2D = $Body
@onready var animated_sprite_2d: AnimatedSprite2D = $Body/AnimatedSprite2D
@onready var anim_hit: AnimationPlayer = $AnimHit
@onready var collision_shape_2d: CollisionShape2D = $Body/Area2D/CollisionShape2D
@onready var progress_bar: ProgressBar = $CanvasLayer/ProgressBar
@onready var sombra: Sprite2D = $Sombra
@onready var ray_cast_2d: RayCast2D = $RayCast2D

# Habilidades aprendidas por el héroe.
var learning = ["Golpe","Dash", "Corte", "CorteDobleSalto", "DashPuas"]

# Atributos exportables.
@export var speed = 250.0 # Velocidad horizontal.
@export var jump_force = -850.0 # Fuerza del salto.
@export var target :CharacterBody2D # Referencia al enemigo objetivo.

# Vida y daño del héroe.
var Health = 25
var force_damage = 1.0

# Estados posibles del héroe.
enum STATES {
	MOVEMENT, IDLE, ATTACK, DASH, HIT, DEATH
}

# Estado actual del héroe.
var current_state = STATES.MOVEMENT

# Variables de tiempo para dash y ataques.
var dash_time = 0.0
var timing_attack = 0.0
var time_attack_max = 0.25
var dash_pass_idle = false

# Se inicializa el personaje, cargando sus valores desde una variable global.
func _ready() -> void:
	learning = Global.hero["learning"]
	Health = Global.hero["health"]
	force_damage = Global.hero["force"]
	progress_bar.max_value = Health
	target.UsePuas.connect(react_puas)
	if learning.has("Golpe"):
		target.UseGolpe.connect(react_golpe)

# Reacción al recibir el evento de golpe del jefe.
func react_golpe():
	if current_state == STATES.MOVEMENT:
		if target.global_position.distance_to(global_position) < 375:
				if is_on_floor():
					if body.scale.x < 0:
						body.scale.x = abs(body.scale.x)
					else:
						body.scale.x = -body.scale.x
					current_state = STATES.DASH
					animated_sprite_2d.play("Dash")
					dash_time = 0.0
					dash_pass_idle = true

# Reacción al recibir el evento de púas del jefe.
func react_puas():
	if current_state == STATES.MOVEMENT:
		if learning.has("DashPuas") and target.global_position.distance_to(global_position) < 415:
				if is_on_floor():
					current_state = STATES.DASH
					animated_sprite_2d.play("Dash")
					dash_time = 0.0
					await get_tree().create_timer(0.1).timeout
					current_state = STATES.DASH
					animated_sprite_2d.play("Dash")
					dash_time = 0.0
					await get_tree().create_timer(0.13).timeout
					animated_sprite_2d.play("Corte")
					current_state = STATES.ATTACK
					velocity.x = 0.0

# Ciclo principal de física del personaje.
func _physics_process(delta: float) -> void:
	progress_bar.value = Health
	timing_attack += delta
	
	if not is_on_floor():
		velocity += get_gravity() * delta * 3.5
	
	match current_state:
		# Estado de movimiento normal.
		STATES.MOVEMENT:
			# Mover hacia el enemigo.
			if target.global_position.x < global_position.x:
				velocity.x = -1
			else:
				velocity.x = 1
			body.scale.x = velocity.x
			velocity.x *= speed

			# Reproduce animaciones según si está en el suelo o no.
			if is_on_floor():
				animated_sprite_2d.play("Run")
			else:
				animated_sprite_2d.play("Jump")
			
			# Salto de corte si el enemigo está en el aire.
			if learning.has("Corte") and target.global_position.distance_to(global_position) > 280:
				if is_on_floor() and !target.is_on_floor():
					Jump()
					current_state = STATES.ATTACK
					velocity.x = 0.0
					if learning.has("CorteDobleSalto"):
						await get_tree().create_timer(0.25).timeout
						Jump()
						await get_tree().create_timer(0.35).timeout
						animated_sprite_2d.play("Corte")
					else:
						await get_tree().create_timer(0.15).timeout
						animated_sprite_2d.play("Corte")
			
			# Dash si está lejos del enemigo.
			if learning.has("Dash") and target.global_position.distance_to(global_position) > 400:
				if is_on_floor():
					current_state = STATES.DASH
					animated_sprite_2d.play("Dash")
					dash_time = 0.0
			
			# Ataque básico si está lo suficientemente cerca del enemigo.
			if target.global_position.distance_to(global_position) < 125 and timing_attack >= time_attack_max:
				if is_on_floor():
					current_state = STATES.ATTACK
					animated_sprite_2d.play("Attack" + str(randi() % 2 + 1))
					collision_shape_2d.set_deferred("disabled", false)
					velocity.x = 0.0
					timing_attack = 0.0
			
		# Estado inactivo.
		STATES.IDLE:
			animated_sprite_2d.play("Idle")
			velocity.x = 0.0

		# Estado de ataque. No se aplica lógica aquí.
		STATES.ATTACK:
			pass

		# Estado de dash, se mueve rápido hacia adelante.
		STATES.DASH:
			dash_time += delta
			if dash_time > 0.1:
				dash_time = 0.0
				if dash_pass_idle == true:
					current_state = STATES.IDLE
					dash_pass_idle = false
					await get_tree().create_timer(0.45).timeout
					current_state = STATES.MOVEMENT
				else:
					current_state = STATES.MOVEMENT
			
			velocity.x = body.scale.x * 1600

		# Estado de ser golpeado.
		STATES.HIT:
			pass

		# Estado de muerte.
		STATES.DEATH:
			velocity.x = 0.0
	
	move_and_slide()
	if ray_cast_2d.is_colliding():
		sombra.global_position = ray_cast_2d.get_collision_point()

# Método de salto.
func dash():
	pass

# Aplica la fuerza de salto al personaje.
func Jump():
	velocity.y = jump_force

# Reacciona al finalizar una animación de ataque.
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation in ["Corte", "Attack1", "Attack2"]:
		current_state = STATES.MOVEMENT
		collision_shape_2d.set_deferred("disabled", true)
		if animated_sprite_2d.animation == "Corte":
			var c = preload("res://Gameplay/Nodes/Slash Hero.tscn").instantiate()
			get_parent().call_deferred("add_child", c)
			c.global_position = $Body/Marker2D.global_position
			c.scale.x = body.scale.x

# El personaje recibe daño.
func Hit(force = 10.0):
	if current_state == STATES.DEATH:
		return
	
	$Hit.play()
	Health -= force
	progress_bar.value = Health
	velocity.x = 0
	velocity.y = 0
	current_state = STATES.HIT
	anim_hit.play("Hit")
	collision_shape_2d.set_deferred("disabled", true)
	var c = preload("res://Assets/Particles/particles_damage.tscn").instantiate()
	c.global_position = global_position
	get_parent().call_deferred("add_child", c)
	c.restart()
	if Health <= 0:
		death()

# Reproduce partículas de muerte de forma secuencial.
func particlesDeath():
	var delay = 0.0
	for i in $ParticlesDeath.get_children():
		await get_tree().create_timer(delay).timeout
		i.restart()
		delay += 0.025

# Muerte del personaje y transición de etapa.
func death():
	particlesDeath()
	set_physics_process(false)
	animated_sprite_2d.play("Death")
	current_state = STATES.DEATH
	Global.hero["health"] += 25
	Global.hero["force"] += 0.65
	get_parent().UpdateIA()
	Global.Stage += 1

	if Global.Final == "A":
		$AlmaDestrozada.emitting = true
		await get_tree().create_timer(3.5).timeout
		$AlmaDestrozada.emitting = false
		$Body.hide()
		$AlmaDestrozadaExplotar.restart()
		var g : CameraShake = get_tree().get_first_node_in_group("CameraGame")
		if g:
			g.Shake(50, 3, 0.05, 50)
		await get_tree().create_timer(3.8).timeout
		var game_over = preload("res://Gameplay/Scenes/game_win.tscn").instantiate()
		get_parent().call_deferred("add_child", game_over)
		return
	
	await get_tree().create_timer(4.0).timeout
	$"../Win/AnimationPlayer".play("End")

# Transición después de recibir golpe.
func _on_anim_hit_animation_finished(anim_name: StringName) -> void:
	if current_state == STATES.DEATH:
		return
	current_state = STATES.MOVEMENT

# Colisión con otros cuerpos: les aplica daño si tienen el método `Hit`.
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("Hit"):
		body.Hit(force_damage)

# Reacción al evento "fire_ball" del enemigo.
func _on_node_2d_fire_ball() -> void:
	if learning.has("FireBall") and current_state == STATES.MOVEMENT:
		Jump()
		await get_tree().create_timer(0.1).timeout
		Jump()
		await get_tree().create_timer(0.1).timeout
		Jump()
		await get_tree().create_timer(0.35).timeout
		animated_sprite_2d.play("Corte")

# Reacción al evento "manos" del enemigo.
func _on_node_2d_manos() -> void:
	if is_on_floor() and learning.has("ManosDemon") and current_state == STATES.MOVEMENT:
		current_state = STATES.DASH
		animated_sprite_2d.play("Dash")
		dash_time = 0.0
		await get_tree().create_timer(0.1).timeout
		current_state = STATES.DASH
		animated_sprite_2d.play("Dash")
		dash_time = 0.0
		await get_tree().create_timer(0.13).timeout
		animated_sprite_2d.play("Corte")
		current_state = STATES.ATTACK
		velocity.x = 0.0

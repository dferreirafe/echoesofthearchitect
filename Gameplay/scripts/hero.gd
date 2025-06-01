class_name Hero
extends CharacterBody2D

@onready var body: Node2D = $Body
@onready var animated_sprite_2d: AnimatedSprite2D = $Body/AnimatedSprite2D
@onready var anim_hit: AnimationPlayer = $AnimHit
@onready var collision_shape_2d: CollisionShape2D = $Body/Area2D/CollisionShape2D
@onready var progress_bar: ProgressBar = $CanvasLayer/ProgressBar


var learning = ["Dash", "Corte", "CorteDobleSalto", "DashPuas"]

@export var speed = 250.0
@export var jump_force = -850.0
@export var target :CharacterBody2D


var Health = 150
var force_damage = 3.5

enum STATES {
	MOVEMENT, IDLE, ATTACK, DASH, HIT, DEATH
}

var current_state = STATES.MOVEMENT


var dash_time = 0.0
var timing_attack = 0.0
var time_attack_max = 0.25

func _ready() -> void:
	learning = Global.hero["learning"]
	Health = Global.hero["health"]
	force_damage = Global.hero["force"]
	progress_bar.max_value = Health
	target.UsePuas.connect(react_puas)


func react_puas():
	if current_state == STATES.MOVEMENT:
		if learning.has("DashPuas") and target.global_position.distance_to(global_position) < 375:
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

func _physics_process(delta: float) -> void:
	progress_bar.value = Health
	timing_attack += delta
	
	if not is_on_floor():
		velocity += get_gravity() * delta * 3.5
	
	
	match current_state:
		STATES.MOVEMENT:
			if target.global_position.x < global_position.x:
				velocity.x = -1
			else:
				velocity.x = 1
			body.scale.x = velocity.x
			velocity.x *= speed
			if is_on_floor():
				animated_sprite_2d.play("Run")
			else:
				animated_sprite_2d.play("Jump")
			
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
			
			if learning.has("Dash") and target.global_position.distance_to(global_position) > 400:
				if is_on_floor():
					current_state = STATES.DASH
					animated_sprite_2d.play("Dash")
					dash_time = 0.0
			
			if target.global_position.distance_to(global_position) < 125 and timing_attack >= time_attack_max:
				if is_on_floor():
					current_state = STATES.ATTACK
					animated_sprite_2d.play("Attack" + str(randi() % 2 + 1))
					collision_shape_2d.set_deferred("disabled", false)
					velocity.x = 0.0
					timing_attack = 0.0
			
		STATES.IDLE:
			velocity.x = 0.0
		STATES.ATTACK:
			pass
		STATES.DASH:
			dash_time += delta
			if dash_time > 0.1:
				dash_time = 0.0
				current_state = STATES.MOVEMENT
			
			velocity.x = body.scale.x * 1600

		STATES.HIT:
			pass
		
		STATES.DEATH:
			velocity.x = 0.0
	
	move_and_slide()


func dash():
	pass


func Jump():
	velocity.y = jump_force


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation in ["Corte", "Attack1", "Attack2"]:
		current_state = STATES.MOVEMENT
		collision_shape_2d.set_deferred("disabled", true)


func Hit(force = 10.0):
	if current_state == STATES.DEATH:
		return
	
	Health -= force
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
		set_physics_process(false)
		animated_sprite_2d.play("Death")
		current_state = STATES.DEATH
		Global.hero["health"] += 85
		Global.hero["force"] += 2.5
		var learnings_nexts =  ["Dash", "Corte", "CorteDobleSalto", "DashPuas"]
		if Global.hero["learning"].size() >= learnings_nexts.size():
			var game_over = preload("res://Gameplay/Scenes/game_win.tscn").instantiate()
			get_parent().call_deferred("add_child", game_over)
			return
		else:
			Global.hero["learning"].append(learnings_nexts[Global.hero["learning"].size()])
		await get_tree().create_timer(1.0).timeout
		$"../Win/AnimationPlayer".play("End")
		
	

func _on_anim_hit_animation_finished(anim_name: StringName) -> void:
	if current_state == STATES.DEATH:
		return
	current_state = STATES.MOVEMENT


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("Hit"):
		body.Hit(force_damage)

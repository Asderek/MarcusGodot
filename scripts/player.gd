class_name Player
extends CharacterBody2D

signal health_changed(current_hp: int, max_hp: int)
signal died

# --- Movement Parameters ---
@export var speed: float = 260.0
@export var acceleration: float = 1800.0
@export var friction: float = 1400.0

# --- Jump Parameters (SotN Feel) ---
@export var jump_velocity: float = -460.0
@export var gravity_scale_up: float = 1.0
@export var gravity_scale_down: float = 1.6
@export var jump_cut_multiplier: float = 0.5

# --- Backdash Parameters (SotN Signature) ---
@export var backdash_speed: float = 380.0
@export var backdash_duration: float = 0.28
@export var backdash_cooldown: float = 0.45

# --- Attack Parameters ---
@export var attack_duration: float = 0.22
@export var attack_cooldown: float = 0.35

# --- Health & State ---
var max_hp: int = 100
var current_hp: int = 100

var default_gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity", 980.0)

var facing_dir: int = 1 # 1 = right, -1 = left
var is_backdashing: bool = false
var backdash_timer: float = 0.0
var backdash_cd_timer: float = 0.0

var is_attacking: bool = false
var attack_timer: float = 0.0
var attack_cd_timer: float = 0.0

# Coyote time & jump buffer
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
const COYOTE_TIME: float = 0.12
const JUMP_BUFFER_TIME: float = 0.12

# Nodes
@onready var body_polygon: Polygon2D = $BodyPolygon
@onready var attack_area: Area2D = $AttackArea
@onready var attack_polygon: Polygon2D = $AttackArea/AttackPolygon
@onready var attack_collision: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var trail_container: Node2D = $TrailContainer

func _ready() -> void:
	# Hide attack hitbox by default
	if attack_area:
		attack_area.monitoring = false
	if attack_polygon:
		attack_polygon.visible = false

func _physics_process(delta: float) -> void:
	_update_timers(delta)
	_handle_gravity(delta)
	
	if not is_backdashing and not is_attacking:
		_handle_jump()
		_handle_horizontal_movement(delta)
		_handle_action_inputs()
	elif is_backdashing:
		_process_backdash(delta)
	elif is_attacking:
		_process_attack(delta)
		
	move_and_slide()
	_update_visuals()

func _update_timers(delta: float) -> void:
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta

	if jump_buffer_timer > 0.0:
		jump_buffer_timer -= delta

	if backdash_cd_timer > 0.0:
		backdash_cd_timer -= delta

	if attack_cd_timer > 0.0:
		attack_cd_timer -= delta

func _handle_gravity(delta: float) -> void:
	if not is_on_floor():
		var grav = default_gravity
		if velocity.y > 0:
			grav *= gravity_scale_down
		else:
			grav *= gravity_scale_up
		velocity.y += grav * delta

func _handle_jump() -> void:
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME

	# Variable jump height cut
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= jump_cut_multiplier

	# Execute jump with Coyote time and Jump Buffer
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = jump_velocity
		jump_buffer_timer = 0.0
		coyote_timer = 0.0

func _handle_horizontal_movement(delta: float) -> void:
	var move_input = Input.get_axis("move_left", "move_right")

	if move_input != 0:
		facing_dir = 1 if move_input > 0 else -1
		velocity.x = move_toward(velocity.x, move_input * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

func _handle_action_inputs() -> void:
	# Backdash trigger
	if Input.is_action_just_pressed("backdash") and backdash_cd_timer <= 0.0 and is_on_floor():
		_start_backdash()
		return

	# Attack trigger
	if Input.is_action_just_pressed("attack") and attack_cd_timer <= 0.0:
		_start_attack()

func _start_backdash() -> void:
	is_backdashing = true
	backdash_timer = backdash_duration
	backdash_cd_timer = backdash_cooldown
	# SotN Backdash moves backwards relative to facing direction
	velocity.x = -facing_dir * backdash_speed
	velocity.y = 0.0
	_spawn_backdash_trail()

func _process_backdash(delta: float) -> void:
	backdash_timer -= delta
	velocity.x = -facing_dir * backdash_speed
	
	# Spawn trail ghosts during backdash
	if Engine.get_physics_frames() % 3 == 0:
		_spawn_backdash_trail()

	if backdash_timer <= 0.0:
		is_backdashing = false
		velocity.x = 0.0

func _start_attack() -> void:
	is_attacking = true
	attack_timer = attack_duration
	attack_cd_timer = attack_cooldown
	
	if attack_area:
		attack_area.monitoring = true
	if attack_polygon:
		attack_polygon.visible = true
	
	_position_attack_area()

func _process_attack(delta: float) -> void:
	attack_timer -= delta
	# Slow down slightly during attack on ground
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0.0, friction * delta * 2.0)

	if attack_timer <= 0.0:
		is_attacking = false
		if attack_area:
			attack_area.monitoring = false
		if attack_polygon:
			attack_polygon.visible = false

func _position_attack_area() -> void:
	if attack_area:
		attack_area.position.x = facing_dir * 38.0
		attack_area.scale.x = facing_dir

func _update_visuals() -> void:
	if body_polygon:
		# Flip body or indicators if facing left
		body_polygon.scale.x = facing_dir
	_position_attack_area()

func _spawn_backdash_trail() -> void:
	if not body_polygon:
		return
	var trail = body_polygon.duplicate() as Polygon2D
	trail.global_position = body_polygon.global_position
	trail.scale = body_polygon.global_scale
	trail.color = Color(0.3, 0.6, 1.0, 0.45) # SotN blue ghost trail
	get_parent().add_child(trail)
	
	var tween = create_tween()
	tween.tween_property(trail, "modulate:a", 0.0, 0.3)
	tween.tween_callback(trail.queue_free)

func take_damage(amount: int) -> void:
	current_hp = max(0, current_hp - amount)
	health_changed.emit(current_hp, max_hp)
	if current_hp <= 0:
		died.emit()

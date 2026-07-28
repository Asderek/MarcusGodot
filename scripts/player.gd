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
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_polygon: Polygon2D = $AttackArea/AttackPolygon
@onready var attack_collision: CollisionShape2D = $AttackArea/CollisionShape2D

func _ready() -> void:
	if attack_area:
		attack_area.monitoring = false
	if attack_polygon:
		attack_polygon.visible = false
		
	_setup_sprite_frames()

func _setup_sprite_frames() -> void:
	if not sprite:
		return
		
	var sf = SpriteFrames.new()
	sf.remove_animation("default")
	
	_add_anim_frames(sf, "idle", 8.0, true, 10)
	_add_anim_frames(sf, "walk", 10.0, true, 7)
	_add_anim_frames(sf, "backdash", 16.0, false, 12)
	_add_anim_frames(sf, "jump", 12.0, false, 10)
	_add_anim_frames(sf, "fall", 8.0, true, 8)
	_add_anim_frames(sf, "attack", 16.0, false, 10)
	
	sprite.sprite_frames = sf
	if sf.has_animation("idle"):
		sprite.play("idle")

func _add_anim_frames(sf: SpriteFrames, anim_name: String, speed_val: float, loop_val: bool, max_frames: int) -> void:
	if not sf.has_animation(anim_name):
		sf.add_animation(anim_name)
	sf.set_animation_speed(anim_name, speed_val)
	sf.set_animation_loop(anim_name, loop_val)
	
	for i in range(max_frames):
		var path = "res://assets/sprites/alucard/" + anim_name + "/" + anim_name + "_" + str(i) + ".png"
		if ResourceLoader.exists(path):
			var tex = load(path) as Texture2D
			if tex:
				sf.add_frame(anim_name, tex)

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
	_update_animation()

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

	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= jump_cut_multiplier

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
	if Input.is_action_just_pressed("backdash") and backdash_cd_timer <= 0.0 and is_on_floor():
		_start_backdash()
		return

	if Input.is_action_just_pressed("attack") and attack_cd_timer <= 0.0:
		_start_attack()

func _start_backdash() -> void:
	is_backdashing = true
	backdash_timer = backdash_duration
	backdash_cd_timer = backdash_cooldown
	velocity.x = -facing_dir * backdash_speed
	velocity.y = 0.0
	_spawn_backdash_trail()

func _process_backdash(delta: float) -> void:
	backdash_timer -= delta
	velocity.x = -facing_dir * backdash_speed
	
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

func _update_animation() -> void:
	if not sprite or not sprite.sprite_frames:
		return

	sprite.flip_h = (facing_dir == -1)
	_position_attack_area()

	if is_backdashing and sprite.sprite_frames.has_animation("backdash"):
		sprite.play("backdash")
	elif is_attacking and sprite.sprite_frames.has_animation("attack"):
		sprite.play("attack")
	elif not is_on_floor():
		if velocity.y < 0 and sprite.sprite_frames.has_animation("jump"):
			sprite.play("jump")
		elif velocity.y >= 0 and sprite.sprite_frames.has_animation("fall"):
			sprite.play("fall")
	else:
		if abs(velocity.x) > 10.0 and sprite.sprite_frames.has_animation("walk"):
			sprite.play("walk")
		elif sprite.sprite_frames.has_animation("idle"):
			sprite.play("idle")

func _spawn_backdash_trail() -> void:
	if not sprite or not sprite.sprite_frames:
		return
	
	if not sprite.sprite_frames.has_animation(sprite.animation):
		return
		
	var frame_count = sprite.sprite_frames.get_frame_count(sprite.animation)
	if frame_count == 0:
		return

	var current_frame = clamp(sprite.frame, 0, frame_count - 1)
	var frame_tex = sprite.sprite_frames.get_frame_texture(sprite.animation, current_frame)
	if not frame_tex:
		return

	var ghost = Sprite2D.new()
	ghost.texture = frame_tex
	ghost.global_position = sprite.global_position
	ghost.flip_h = sprite.flip_h
	ghost.scale = sprite.scale
	ghost.modulate = Color(0.3, 0.6, 1.0, 0.6) # Classic Alucard blue ghost trail
	get_parent().add_child(ghost)
	
	var tween = create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, 0.28)
	tween.tween_callback(ghost.queue_free)

func take_damage(amount: int) -> void:
	current_hp = max(0, current_hp - amount)
	health_changed.emit(current_hp, max_hp)
	if current_hp <= 0:
		died.emit()

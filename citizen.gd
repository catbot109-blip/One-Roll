extends CharacterBody3D

@export var is_murderer: bool = false
@export var npc_name: String = "Citizen"
@export var dialogue_lines: Array[String] = ["Howdy, sheriff.", "Nice day, ain't it?"]

@export var wander_radius: float = 5.0
@export var move_speed: float = 2.0
@export var wait_time_min: float = 1.5
@export var wait_time_max: float = 4.0

@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D

var start_position: Vector3
var target_position: Vector3
var wait_timer: float = 0.0
var is_waiting: bool = true

func _ready() -> void:
	sprite.play("idle")
	start_position = global_position
	_pick_new_target()

func _physics_process(delta: float) -> void:
	if is_waiting:
		wait_timer -= delta
		velocity = Vector3.ZERO
		if wait_timer <= 0.0:
			_pick_new_target()
	else:
		var direction: Vector3 = (target_position - global_position)
		direction.y = 0.0
		
		if direction.length() < 0.2:
			# Reached target, start waiting
			is_waiting = true
			wait_timer = randf_range(wait_time_min, wait_time_max)
			velocity = Vector3.ZERO
		else:
			direction = direction.normalized()
			velocity = direction * move_speed
			# Face movement direction (rotate the whole body)
			look_at(global_position + direction, Vector3.UP)

	move_and_slide()

	# Switch animation based on movement speed
	if velocity.length() > 0.1:
		if sprite.animation != "walk":
			sprite.play("walk")
	else:
		if sprite.animation != "idle":
			sprite.play("idle")

func _pick_new_target() -> void:
	var random_offset := Vector3(
		randf_range(-wander_radius, wander_radius),
		0.0,
		randf_range(-wander_radius, wander_radius)
	)
	target_position = start_position + random_offset
	is_waiting = false

func interact() -> String:
	if dialogue_lines.size() > 0:
		return dialogue_lines[randi() % dialogue_lines.size()]
	return "..."

extends CharacterBody3D

@export var is_murderer: bool = false
@export var npc_name: String = "Citizen"
@export var dialogue_lines: Array[String] = ["Howdy, sheriff.", "Nice day, ain't it?"]
@export var zone_name: String = ""
@export var wander_radius: float = 5.0
@export var move_speed: float = 2.0
@export var wait_time_min: float = 1.5
@export var wait_time_max: float = 4.0

@export var interact_cooldown: float = 1.0

# Pitch variation range for the talk SFX
@export var pitch_min: float = 0.95
@export var pitch_max: float = 2.0

# Murder Settings
@export var sheriff_safe_radius: float = 15.0 # How close the sheriff must be to prevent a murder
@export var kill_range: float = 2.5           # Distance to victim to strike
@export var kill_cooldown: float = 4.0        # Seconds between murders

@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D
@onready var label: Label3D = $Label3D
@onready var talk_audio: AudioStreamPlayer3D = $TalkAudio

# Finds the sheriff automatically
@onready var sheriff: Node3D = get_tree().root.find_child("CharacterBody3D", true, false)

var start_position: Vector3
var target_position: Vector3
var wait_timer: float = 0.0
var is_waiting: bool = true

var cooldown_timer: float = 0.0
var dialogue_display_time: float = 0.0

var kill_timer: float = 0.0
var is_dead: bool = false

func _ready() -> void:
	sprite.play("idle")
	label.text = ""
	start_position = global_position
	_pick_new_target()

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# Handle Murder Logic
	if is_murderer:
		if kill_timer > 0.0:
			kill_timer -= delta
		else:
			_attempt_murder()

	if cooldown_timer > 0.0:
		cooldown_timer -= delta

	if dialogue_display_time > 0.0:
		dialogue_display_time -= delta
		if dialogue_display_time <= 0.0:
			label.text = ""

	if is_waiting:
		wait_timer -= delta
		velocity = Vector3.ZERO
		if wait_timer <= 0.0:
			_pick_new_target()
	else:
		var direction: Vector3 = (target_position - global_position)
		direction.y = 0.0

		if direction.length() < 0.2:
			is_waiting = true
			wait_timer = randf_range(wait_time_min, wait_time_max)
			velocity = Vector3.ZERO
		else:
			direction = direction.normalized()
			velocity = direction * move_speed
			look_at(global_position + direction, Vector3.UP)

	move_and_slide()

	if velocity.length() > 0.1:
		if sprite.animation != "walk":
			sprite.play("walk")
	else:
		if sprite.animation != "idle":
			sprite.play("idle")

func _attempt_murder() -> void:
	if not sheriff:
		return

	# 1. Check if Sheriff is near
	var dist_to_sheriff: float = global_position.distance_to(sheriff.global_position)
	if dist_to_sheriff < sheriff_safe_radius:
		return # SHERIFF NEAR. ACT NATURAL.

	# 2. Look for nearby innocent victims
	var all_nodes: Array = get_parent().get_children()
	for victim in all_nodes:
		if "Citizen" in victim.name and victim != self and not victim.is_queued_for_deletion():
			if "is_dead" in victim and victim.is_dead:
				continue
				
			var dist_to_victim: float = global_position.distance_to(victim.global_position)
			if dist_to_victim < kill_range:
				print("MURDER! ", name, " secretly eliminated ", victim.name, "!")
				
				# Triggers their death sequence
				if victim.has_method("take_damage"):
					victim.take_damage(100)
				else:
					victim.queue_free()
				
				kill_timer = kill_cooldown
				return

func _pick_new_target() -> void:
	var random_offset := Vector3(
		randf_range(-wander_radius, wander_radius),
		0.0,
		randf_range(-wander_radius, wander_radius)
	)
	target_position = start_position + random_offset
	is_waiting = false

func can_interact() -> bool:
	return cooldown_timer <= 0.0 and not is_dead

func interact() -> String:
	if not can_interact():
		return ""

	var line: String = ""
	if dialogue_lines.size() > 0:
		line = dialogue_lines[randi() % dialogue_lines.size()]

	label.text = line
	dialogue_display_time = 3.0
	cooldown_timer = interact_cooldown

	# Play dialogue sound effect immediately
	if talk_audio and talk_audio.stream:
		talk_audio.pitch_scale = randf_range(pitch_min, pitch_max)
		talk_audio.play()

	return line

func take_damage(_amount: int) -> void:
	if is_dead:
		return

	_die()

	if is_murderer:
		print("CASE SOLVED - you got the murderer!")
	else:
		print("You shot an innocent citizen! That's on you, sheriff.")

func _die() -> void:
	if is_dead:
		return

	is_dead = true
	sprite.play("dead")

extends Camera3D

@export var damage: int = 25
@export var max_range: float = 100.0
@export var fire_cooldown: float = 0.4

# Audio node reference
@onready var gun_audio: AudioStreamPlayer3D = $GunAudio

var cooldown_timer: float = 0.0

func _physics_process(delta: float) -> void:
	if cooldown_timer > 0.0:
		cooldown_timer -= delta

	if Input.is_action_just_pressed("shoot") and cooldown_timer <= 0.0:
		_shoot()
		cooldown_timer = fire_cooldown

func _shoot() -> void:
	# Play gun sound effect
	if gun_audio and gun_audio.stream:
		gun_audio.play()

	var world_3d := get_world_3d()
	if not world_3d:
		return

	var space_state := world_3d.direct_space_state
	var from: Vector3 = global_position
	var to: Vector3 = from - global_transform.basis.z * max_range

	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_bodies = true

	var result := space_state.intersect_ray(query)

	# In Godot 4, the object key is "collider", not "body"
	if result and result.has("collider"):
		var hit_body: Object = result["collider"]
		print("Hit: ", hit_body.name)
		if hit_body.has_method("take_damage"):
			hit_body.take_damage(damage)

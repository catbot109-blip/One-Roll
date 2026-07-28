extends Area3D

var nearby_citizens: Array[Node3D] = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body.has_method("interact"):
		nearby_citizens.append(body)

func _on_body_exited(body: Node3D) -> void:
	if nearby_citizens.has(body):
		nearby_citizens.erase(body)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and nearby_citizens.size() > 0:
		var closest: Node3D = nearby_citizens[0]
		var line: String = closest.interact()
		print(line)  # We'll replace this with actual UI text next

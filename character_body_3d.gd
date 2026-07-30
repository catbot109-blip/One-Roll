extends Node3D

func _ready() -> void:
	_create_crosshair()

	# Wait a split second so all Citizens have time to load in fully
	await get_tree().create_timer(0.2).timeout
	_pick_random_murderer()

func _create_crosshair() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)

	var label := Label.new()
	label.text = "+"
	label.add_theme_font_size_override("font_size", 24)
	label.set_anchors_preset(Control.PRESET_CENTER)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	canvas.add_child(label)

func _pick_random_murderer() -> void:
	var all_citizens: Array = []

	# Loop through all nodes directly under the root Node3D
	for child in get_children():
		# Check if the node's name contains "Citizen"
		if "Citizen" in child.name:
			all_citizens.append(child)
			# Make sure everyone starts innocent
			child.is_murderer = false

	# Pick a random one if we found any
	if all_citizens.size() > 0:
		var murderer = all_citizens.pick_random()
		murderer.is_murderer = true

		# Changes their Label3D to red just for testing so you can see who it is!
		if murderer.has_node("Label3D"):
			murderer.get_node("Label3D").modulate = Color(1, 0, 0)

		print("The murderer this round is: ", murderer.name)
	else:
		print("Sheriff, the town is empty! No citizens found.")

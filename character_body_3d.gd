extends Node3D

func _ready() -> void:
	_create_crosshair()
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
	for child in get_children():
		if "Citizen" in child.name:
			all_citizens.append(child)
			child.is_murderer = false

	for c in all_citizens:
		print("Citizen: ", c.name, " | Zone: '", c.zone_name, "'")

	if all_citizens.size() > 0:
		var murderer = all_citizens.pick_random()
		murderer.is_murderer = true
		print("The murderer this round is: ", murderer.name)
		print("DEBUG: Murderer's zone_name is: '", murderer.zone_name, "'")
		_assign_witness_clue(murderer, all_citizens)
	else:
		print("Sheriff!")

func _assign_witness_clue(murderer: Node, all_citizens: Array) -> void:
	var possible_witnesses: Array = all_citizens.filter(func(c): return c != murderer)
	if possible_witnesses.size() == 0:
		return
	var witness = possible_witnesses.pick_random()
	if murderer.zone_name != "":
		var clue_text: String = "I saw someone suspicious near the " + murderer.zone_name + " not too long ago."
		witness.dialogue_lines.append(clue_text)
		print("(DEBUG) Witness ", witness.name, " now knows a clue pointing to the ", murderer.zone_name)

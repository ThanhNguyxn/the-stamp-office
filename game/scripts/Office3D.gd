extends Node3D
## Office3D - 3D office environment with ambient effects, rooms, and interactables
## Provides tremor effects, light flickering, flavor triggers, and passive-aggressive signage

signal show_toast(message: String)

@onready var clerk: Node3D = get_node_or_null("Clerk")
@onready var main_light: OmniLight3D = get_node_or_null("MainRoomLight")
@onready var corridor_light1: OmniLight3D = get_node_or_null("CorridorLight1")
@onready var corridor_light2: OmniLight3D = get_node_or_null("CorridorLight2")

var camera: Camera3D = null
var head: Node3D = null
var player: CharacterBody3D = null

var time: float = 0.0
var clerk_base_y: float = 0.0
var head_base_pos: Vector3
var main_light_energy: float = 1.0

var flicker_timer: float = 0.0
var next_flicker: float = 5.0

# Room visit tracking
var visited_rooms: Dictionary = {}

# Passive-aggressive signs
const OFFICE_SIGNS: Array = [
	"REQUEST DENIED.\nTRY AGAIN NEVER.",
	"PLEASE WALK NORMALLY.",
	"LAUGHTER IS A\nDOCUMENTED INCIDENT.",
	"IF YOU SEE YOURSELF,\nFILE A TICKET.",
	"DO NOT KNOCK.\nDO NOT THINK.",
	"COFFEE IS A PRIVILEGE,\nNOT A RIGHT.",
	"SILENCE MEANS\nCONSENT TO OVERTIME.",
	"YOUR BREAK ENDED\n5 MINUTES AGO.",
	"THIS DOOR IS NOT\nAN EXIT. OR IS IT?",
	"PRODUCTIVITY IS\nMANDATORY HAPPINESS.",
	"DREAMS ARE FOR\nOFF-DUTY HOURS ONLY.",
	"COMPLAINTS GO IN\nTHE SHREDDER."
]

const ROOM_MESSAGES: Dictionary = {
	"lobby": "Welcome back. Your shift never ends.",
	"break_room": "The coffee machine watches. It judges.",
	"printer_room": "The printer breathes. Do not wake it.",
	"archive": "The files remember what you forgot.",
	"manager_door": "DO NOT KNOCK. The Manager is always busy.",
	"break_room_b": "Break Room B does not exist. You did not see this.",
	"stairwell": "ACCESS DENIED. Floor -1 is classified."
}

func _ready() -> void:
	if clerk:
		clerk_base_y = clerk.position.y
	
	player = find_child("Player", true, false) as CharacterBody3D
	camera = find_child("Camera3D", true, false) as Camera3D
	
	if camera:
		head = camera.get_parent() as Node3D
		if head:
			head_base_pos = head.position
	
	if main_light:
		main_light_energy = main_light.light_energy
	
	# Build additional office elements
	call_deferred("_build_office_details")
	call_deferred("_connect_triggers")
	call_deferred("_connect_player_signals")

func _connect_player_signals() -> void:
	if player and player.has_signal("interacted_with"):
		player.connect("interacted_with", _on_player_interacted)

func _on_player_interacted(object_name: String, obj: Node) -> void:
	match object_name:
		"locked_door":
			var door_name = obj.name if obj else "door"
			if "Manager" in door_name:
				_show_message(ROOM_MESSAGES["manager_door"])
			elif "BreakB" in door_name or "BreakRoomB" in door_name:
				_show_message(ROOM_MESSAGES["break_room_b"])
			else:
				_show_message("This door is locked. For your safety.")
		"door":
			print("[Office] Door toggled")

func _build_office_details() -> void:
	# Add signs throughout the office
	_add_passive_aggressive_signs()
	
	# Add room flavor triggers
	_add_room_triggers()
	
	print("[Office] Office details built")

func _add_passive_aggressive_signs() -> void:
	# Sign positions and rotations [position, rotation_y, sign_index]
	var sign_placements: Array = [
		[Vector3(-3, 2.2, -5), 0, 0],      # Near entrance
		[Vector3(5, 2.2, 0), -PI/2, 1],    # Corridor
		[Vector3(-5, 2.2, -15), PI/2, 2],  # Break room area
		[Vector3(0, 2.2, -25), 0, 3],      # Archive entrance
		[Vector3(8, 2.2, -10), -PI/2, 4],  # Manager door area
		[Vector3(-8, 2.2, 5), PI/2, 5],    # Lobby
	]
	
	var signs_parent = Node3D.new()
	signs_parent.name = "OfficeSigns"
	add_child(signs_parent)
	
	for placement in sign_placements:
		var pos: Vector3 = placement[0]
		var rot: float = placement[1]
		var idx: int = placement[2] % OFFICE_SIGNS.size()
		
		_create_sign_at(signs_parent, pos, rot, OFFICE_SIGNS[idx])

func _create_sign_at(parent: Node3D, pos: Vector3, rot_y: float, text: String) -> void:
	var sign_node = Node3D.new()
	sign_node.position = pos
	sign_node.rotation.y = rot_y
	parent.add_child(sign_node)
	
	# Sign backing board
	var board = MeshInstance3D.new()
	var board_mesh = BoxMesh.new()
	board_mesh.size = Vector3(0.8, 0.5, 0.02)
	board.mesh = board_mesh
	
	var board_mat = StandardMaterial3D.new()
	board_mat.albedo_color = Color(0.15, 0.15, 0.18)
	board.material_override = board_mat
	sign_node.add_child(board)
	
	# Sign text
	var label = Label3D.new()
	label.text = text
	label.font_size = 48
	label.position.z = 0.015
	label.modulate = Color(0.9, 0.3, 0.2)
	label.outline_size = 4
	label.outline_modulate = Color(0, 0, 0)
	sign_node.add_child(label)

func _add_room_triggers() -> void:
	var triggers = get_node_or_null("TriggerZones")
	if not triggers:
		triggers = Node3D.new()
		triggers.name = "TriggerZones"
		add_child(triggers)
	
	# Define trigger zones [name, position, size]
	var room_triggers: Array = [
		["LobbyTrigger", Vector3(0, 1, 10), Vector3(8, 3, 6)],
		["BreakRoomTrigger", Vector3(-6, 1, -12), Vector3(6, 3, 6)],
		["PrinterRoomTrigger", Vector3(6, 1, -8), Vector3(4, 3, 4)],
		["ArchiveTrigger", Vector3(0, 1, -25), Vector3(8, 3, 8)],
		["ManagerDoorTrigger", Vector3(8, 1, -5), Vector3(3, 3, 3)],
	]
	
	for trigger_def in room_triggers:
		var trigger_name: String = trigger_def[0]
		var existing = triggers.get_node_or_null(trigger_name)
		if existing:
			continue
		
		var trigger_pos: Vector3 = trigger_def[1]
		var trigger_size: Vector3 = trigger_def[2]
		
		var area = Area3D.new()
		area.name = trigger_name
		area.position = trigger_pos
		triggers.add_child(area)
		
		var shape = CollisionShape3D.new()
		var box = BoxShape3D.new()
		box.size = trigger_size
		shape.shape = box
		area.add_child(shape)
		
		# Connect signal
		area.body_entered.connect(_on_room_entered.bind(trigger_name))

func _on_room_entered(body: Node3D, trigger_name: String) -> void:
	if body != player:
		return
	
	# Only show message first time
	if visited_rooms.get(trigger_name, false):
		return
	visited_rooms[trigger_name] = true
	
	var room_key = ""
	match trigger_name:
		"LobbyTrigger":
			room_key = "lobby"
		"BreakRoomTrigger":
			room_key = "break_room"
		"PrinterRoomTrigger":
			room_key = "printer_room"
		"ArchiveTrigger":
			room_key = "archive"
		"ManagerDoorTrigger":
			room_key = "manager_door"
	
	if room_key != "":
		var message = ROOM_MESSAGES.get(room_key, "")
		if message != "":
			_show_message(message)
			
			# Special effects for certain rooms
			if room_key == "manager_door":
				apply_tremor(0.2, 0.15)

func _show_message(message: String) -> void:
	print("[Office] Toast: ", message)
	emit_signal("show_toast", message)

func _connect_triggers() -> void:
	var stair_trigger = get_node_or_null("TriggerZones/StairwellTrigger")
	if stair_trigger:
		stair_trigger.body_entered.connect(_on_stairwell_entered)

func _on_stairwell_entered(body: Node3D) -> void:
	if body == player:
		if not visited_rooms.get("stairwell", false):
			visited_rooms["stairwell"] = true
			_show_message(ROOM_MESSAGES["stairwell"])
			apply_tremor(0.3, 0.2)

func _process(delta: float) -> void:
	time += delta
	
	# Clerk idle bob
	if clerk:
		clerk.position.y = clerk_base_y + sin(time * 1.5) * 0.03
		clerk.rotation.y = sin(time * 0.8) * 0.02
	
	# Ambient light flicker
	flicker_timer += delta
	if flicker_timer >= next_flicker:
		_ambient_flicker()
		flicker_timer = 0.0
		next_flicker = randf_range(4.0, 12.0)

func _ambient_flicker() -> void:
	var target_light: OmniLight3D = null
	if randf() > 0.5:
		target_light = corridor_light1
	else:
		target_light = corridor_light2
	
	if not target_light:
		return
	
	var base_energy = target_light.light_energy
	var tween = create_tween()
	tween.tween_property(target_light, "light_energy", base_energy * 0.2, 0.05)
	tween.tween_property(target_light, "light_energy", base_energy * 0.8, 0.03)
	tween.tween_property(target_light, "light_energy", base_energy * 0.3, 0.04)
	tween.tween_property(target_light, "light_energy", base_energy, 0.1)

func apply_tremor(intensity: float = 0.5, duration: float = 0.3) -> void:
	if not main_light:
		return
	
	if not camera:
		camera = find_child("Camera3D", true, false) as Camera3D
		if camera:
			head = camera.get_parent() as Node3D
			if head:
				head_base_pos = head.position
	
	if head:
		var shake_tween = create_tween()
		shake_tween.set_trans(Tween.TRANS_QUAD)
		var shake = intensity * 0.08
		var base = head_base_pos
		shake_tween.tween_property(head, "position", base + Vector3(shake, 0, 0), duration * 0.1)
		shake_tween.tween_property(head, "position", base + Vector3(-shake, shake * 0.5, 0), duration * 0.1)
		shake_tween.tween_property(head, "position", base + Vector3(shake * 0.5, -shake * 0.5, 0), duration * 0.1)
		shake_tween.tween_property(head, "position", base, duration * 0.1)
		shake_tween.tween_callback(_reset_head)
	
	var light_tween = create_tween()
	light_tween.set_trans(Tween.TRANS_QUAD)
	light_tween.tween_property(main_light, "light_energy", main_light_energy * 0.3, duration * 0.15)
	light_tween.tween_property(main_light, "light_energy", main_light_energy * 1.2, duration * 0.1)
	light_tween.tween_property(main_light, "light_energy", main_light_energy * 0.5, duration * 0.1)
	light_tween.tween_property(main_light, "light_energy", main_light_energy, duration * 0.15)
	light_tween.tween_callback(_reset_light)

func _reset_head() -> void:
	if head:
		head.position = head_base_pos

func _reset_light() -> void:
	if main_light:
		main_light.light_energy = main_light_energy

func get_active_camera() -> Camera3D:
	if not camera:
		camera = find_child("Camera3D", true, false) as Camera3D
	return camera

func get_player() -> CharacterBody3D:
	if not player:
		player = find_child("Player", true, false) as CharacterBody3D
	return player

func reset_room_visits() -> void:
	visited_rooms.clear()

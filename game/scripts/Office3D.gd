extends Node3D
## Office3D - 3D office environment with ambient effects
## Provides tremor effects and light flickering

@onready var clerk: Node3D = $Clerk
@onready var main_light: OmniLight3D = $MainRoomLight
@onready var corridor_light1: OmniLight3D = $CorridorLight1
@onready var corridor_light2: OmniLight3D = $CorridorLight2

# Camera/head for tremor
var camera: Camera3D = null
var head: Node3D = null
var player: CharacterBody3D = null

var time: float = 0.0
var clerk_base_y: float = 0.0
var head_base_pos: Vector3
var main_light_energy: float = 1.0

# Ambient flicker
var flicker_timer: float = 0.0
var next_flicker: float = 5.0

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
	
	# Connect trigger zones
	_connect_triggers()

func _connect_triggers() -> void:
	var break_trigger = get_node_or_null("TriggerZones/BreakRoomTrigger")
	if break_trigger:
		break_trigger.body_entered.connect(_on_break_room_entered)
	
	var archive_trigger = get_node_or_null("TriggerZones/ArchiveTrigger")
	if archive_trigger:
		archive_trigger.body_entered.connect(_on_archive_entered)
	
	var stair_trigger = get_node_or_null("TriggerZones/StairwellTrigger")
	if stair_trigger:
		stair_trigger.body_entered.connect(_on_stairwell_entered)

func _on_break_room_entered(body: Node3D) -> void:
	if body == player:
		print("[Office] Player entered Break Room B")

func _on_archive_entered(body: Node3D) -> void:
	if body == player:
		print("[Office] Player entered Archive")

func _on_stairwell_entered(body: Node3D) -> void:
	if body == player:
		print("[Office] Player approached Stairwell - ACCESS DENIED")
		# Mini tremor when approaching forbidden area
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
	# Random corridor light flicker
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

## Apply tremor effect
func apply_tremor(intensity: float = 0.5, duration: float = 0.3) -> void:
	if not main_light:
		return
	
	# Find camera if needed
	if not camera:
		camera = find_child("Camera3D", true, false) as Camera3D
		if camera:
			head = camera.get_parent() as Node3D
			if head:
				head_base_pos = head.position
	
	# Head shake
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
	
	# Light flicker
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

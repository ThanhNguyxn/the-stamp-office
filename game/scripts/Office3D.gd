extends Node3D
## Office3D - 3D office backdrop with clerk silhouette
## Provides idle animation and tremor effects
## Updated to work with Player/Head/Camera3D hierarchy

@onready var clerk: Node3D = $Clerk
@onready var light: DirectionalLight3D = $DirectionalLight3D

# Camera and head found dynamically to support Player rig
var camera: Camera3D = null
var head: Node3D = null
var player: CharacterBody3D = null

var time: float = 0.0
var clerk_base_y: float = 0.0
var head_base_pos: Vector3
var light_base_energy: float = 1.0

func _ready() -> void:
	# Store base values for effects
	if clerk:
		clerk_base_y = clerk.position.y
	
	# Find camera in Player/Head/Camera3D hierarchy
	player = find_child("Player", true, false) as CharacterBody3D
	camera = find_child("Camera3D", true, false) as Camera3D
	
	if camera:
		head = camera.get_parent() as Node3D
		if head:
			head_base_pos = head.position
	
	if light:
		light_base_energy = light.light_energy

func _process(delta: float) -> void:
	time += delta
	
	# Clerk idle bob - small vertical sway
	if clerk:
		clerk.position.y = clerk_base_y + sin(time * 1.5) * 0.03
		clerk.rotation.y = sin(time * 0.8) * 0.02

## Apply tremor effect - camera/head shake + light flicker
## Works with nested camera rig without overwriting player transform
func apply_tremor(intensity: float = 0.5, duration: float = 0.3) -> void:
	if not light:
		return
	
	# Find camera if not cached
	if not camera:
		camera = find_child("Camera3D", true, false) as Camera3D
		if camera:
			head = camera.get_parent() as Node3D
			if head:
				head_base_pos = head.position
	
	# Camera/head shake - apply as local offset on head node
	if head:
		var shake_tween = create_tween()
		shake_tween.set_trans(Tween.TRANS_QUAD)
		var shake_amount = intensity * 0.08  # Smaller for head-relative shake
		var base = head_base_pos
		shake_tween.tween_property(head, "position", base + Vector3(shake_amount, 0, 0), duration * 0.1)
		shake_tween.tween_property(head, "position", base + Vector3(-shake_amount, shake_amount * 0.5, 0), duration * 0.1)
		shake_tween.tween_property(head, "position", base + Vector3(shake_amount * 0.5, -shake_amount * 0.5, 0), duration * 0.1)
		shake_tween.tween_property(head, "position", base, duration * 0.1)
		shake_tween.tween_callback(_reset_head)
	
	# Light flicker - always ends at base energy
	var light_tween = create_tween()
	light_tween.set_trans(Tween.TRANS_QUAD)
	light_tween.tween_property(light, "light_energy", light_base_energy * 0.3, duration * 0.15)
	light_tween.tween_property(light, "light_energy", light_base_energy * 1.2, duration * 0.1)
	light_tween.tween_property(light, "light_energy", light_base_energy * 0.5, duration * 0.1)
	light_tween.tween_property(light, "light_energy", light_base_energy, duration * 0.15)
	light_tween.tween_callback(_reset_light)

## Reset head to base position (prevents drift)
func _reset_head() -> void:
	if head:
		head.position = head_base_pos

## Reset light to base energy (prevents drift)
func _reset_light() -> void:
	if light:
		light.light_energy = light_base_energy

## Get the active camera (for external scripts like Shift.gd)
func get_active_camera() -> Camera3D:
	if not camera:
		camera = find_child("Camera3D", true, false) as Camera3D
	return camera

## Get the player controller (for cursor mode access)
func get_player() -> CharacterBody3D:
	if not player:
		player = find_child("Player", true, false) as CharacterBody3D
	return player

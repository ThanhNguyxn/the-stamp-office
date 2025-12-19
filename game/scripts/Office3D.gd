extends Node3D
## Office3D - 3D office backdrop with clerk silhouette
## Provides idle animation and tremor effects

@onready var clerk: Node3D = $Clerk
@onready var camera: Camera3D = $Camera3D
@onready var light: DirectionalLight3D = $DirectionalLight3D

var time: float = 0.0
var clerk_base_y: float = 0.0
var camera_base_pos: Vector3
var light_base_energy: float = 1.0

func _ready() -> void:
	# Store base values for effects
	if clerk:
		clerk_base_y = clerk.position.y
	if camera:
		camera_base_pos = camera.position
		# Ensure this camera is current (belt + suspenders)
		camera.make_current()
	if light:
		light_base_energy = light.light_energy

func _process(delta: float) -> void:
	time += delta
	
	# Clerk idle bob - small vertical sway
	if clerk:
		clerk.position.y = clerk_base_y + sin(time * 1.5) * 0.03
		clerk.rotation.y = sin(time * 0.8) * 0.02

## Apply tremor effect - camera shake + light flicker
## Always returns to base position to prevent drift
func apply_tremor(intensity: float = 0.5, duration: float = 0.3) -> void:
	if not camera or not light:
		return
	
	# Kill any existing tweens to prevent drift
	var existing_tweens = get_tree().get_processed_tweens()
	
	# Camera shake - always ends at base position
	var shake_tween = create_tween()
	shake_tween.set_trans(Tween.TRANS_QUAD)
	var shake_amount = intensity * 0.15
	shake_tween.tween_property(camera, "position", camera_base_pos + Vector3(shake_amount, 0, 0), duration * 0.1)
	shake_tween.tween_property(camera, "position", camera_base_pos + Vector3(-shake_amount, shake_amount * 0.5, 0), duration * 0.1)
	shake_tween.tween_property(camera, "position", camera_base_pos + Vector3(shake_amount * 0.5, -shake_amount * 0.5, 0), duration * 0.1)
	shake_tween.tween_property(camera, "position", camera_base_pos, duration * 0.1)
	# Ensure camera returns to base after tween completes
	shake_tween.tween_callback(_reset_camera)
	
	# Light flicker - always ends at base energy
	var light_tween = create_tween()
	light_tween.set_trans(Tween.TRANS_QUAD)
	light_tween.tween_property(light, "light_energy", light_base_energy * 0.3, duration * 0.15)
	light_tween.tween_property(light, "light_energy", light_base_energy * 1.2, duration * 0.1)
	light_tween.tween_property(light, "light_energy", light_base_energy * 0.5, duration * 0.1)
	light_tween.tween_property(light, "light_energy", light_base_energy, duration * 0.15)
	# Ensure light returns to base after tween completes
	light_tween.tween_callback(_reset_light)

## Reset camera to base position (prevents drift)
func _reset_camera() -> void:
	if camera:
		camera.position = camera_base_pos

## Reset light to base energy (prevents drift)
func _reset_light() -> void:
	if light:
		light.light_energy = light_base_energy

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
	if clerk:
		clerk_base_y = clerk.position.y
	if camera:
		camera_base_pos = camera.position
	if light:
		light_base_energy = light.light_energy

func _process(delta: float) -> void:
	time += delta
	
	# Clerk idle bob - small vertical sway
	if clerk:
		clerk.position.y = clerk_base_y + sin(time * 1.5) * 0.03
		clerk.rotation.y = sin(time * 0.8) * 0.02

## Apply tremor effect - camera shake + light flicker
func apply_tremor(intensity: float = 0.5, duration: float = 0.3) -> void:
	if not camera or not light:
		return
	
	# Camera shake
	var shake_tween = create_tween()
	var shake_amount = intensity * 0.15
	shake_tween.tween_property(camera, "position", camera_base_pos + Vector3(shake_amount, 0, 0), duration * 0.1)
	shake_tween.tween_property(camera, "position", camera_base_pos + Vector3(-shake_amount, shake_amount * 0.5, 0), duration * 0.1)
	shake_tween.tween_property(camera, "position", camera_base_pos + Vector3(shake_amount * 0.5, -shake_amount * 0.5, 0), duration * 0.1)
	shake_tween.tween_property(camera, "position", camera_base_pos, duration * 0.1)
	
	# Light flicker
	var light_tween = create_tween()
	light_tween.tween_property(light, "light_energy", light_base_energy * 0.3, duration * 0.15)
	light_tween.tween_property(light, "light_energy", light_base_energy * 1.2, duration * 0.1)
	light_tween.tween_property(light, "light_energy", light_base_energy * 0.5, duration * 0.1)
	light_tween.tween_property(light, "light_energy", light_base_energy, duration * 0.15)

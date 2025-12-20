extends Node3D
## Clerk - The mysterious office clerk with creepy animations
## Subtle movements that create unease

@onready var head: MeshInstance3D = $Head
@onready var body: MeshInstance3D = $Body

# Animation state
var is_staring := false
var stare_target: Node3D = null
var idle_time := 0.0
var blink_time := 0.0
var sway_phase := 0.0

# Original transforms
var head_original_rotation: Vector3
var body_original_position: Vector3

# Settings
var animations_enabled := true
var creepy_mode := false  # Becomes true at higher shifts/tension

func _ready() -> void:
	if head:
		head_original_rotation = head.rotation
	if body:
		body_original_position = body.position
	
	_load_settings()

func _load_settings() -> void:
	var save_node = get_node_or_null("/root/Save")
	if save_node and "jumpscares_enabled" in save_node:
		animations_enabled = bool(save_node.jumpscares_enabled)

func _process(delta: float) -> void:
	if not animations_enabled:
		return
	
	idle_time += delta
	blink_time += delta
	sway_phase += delta
	
	if is_staring and stare_target:
		_look_at_target(delta)
	else:
		_idle_animation(delta)
	
	# Random blink
	if blink_time > randf_range(3.0, 8.0):
		blink_time = 0.0
		_do_blink()

func _idle_animation(_delta: float) -> void:
	if not head:
		return
	
	# Subtle breathing sway
	var sway_amount := 0.01 if not creepy_mode else 0.02
	var sway_speed := 1.5 if not creepy_mode else 0.8
	
	var sway := sin(sway_phase * sway_speed) * sway_amount
	head.rotation.z = head_original_rotation.z + sway
	
	# Occasional head tilt
	if int(idle_time) % 10 == 0 and randf() < 0.01:
		_random_head_tilt()

func _look_at_target(delta: float) -> void:
	if not head or not stare_target:
		return
	
	var target_pos := stare_target.global_position
	var head_pos := head.global_position
	var direction := (target_pos - head_pos).normalized()
	
	# Calculate rotation to look at target
	var target_rotation := Vector3.ZERO
	target_rotation.y = atan2(direction.x, direction.z)
	target_rotation.x = -asin(direction.y)
	
	# Clamp rotation
	target_rotation.x = clampf(target_rotation.x, -0.5, 0.5)
	target_rotation.y = clampf(target_rotation.y, -1.0, 1.0)
	
	# Smooth interpolation (creepy slow turn)
	var speed := 0.5 if creepy_mode else 2.0
	head.rotation = head.rotation.lerp(target_rotation, delta * speed)

func _random_head_tilt() -> void:
	if not head:
		return
	
	var tween := create_tween()
	var random_tilt := Vector3(
		randf_range(-0.1, 0.1),
		randf_range(-0.2, 0.2),
		randf_range(-0.1, 0.1)
	)
	
	tween.tween_property(head, "rotation", head_original_rotation + random_tilt, 0.5)
	tween.tween_property(head, "rotation", head_original_rotation, 0.5)

func _do_blink() -> void:
	# Visual blink effect - scale head slightly
	if not head:
		return
	
	var tween := create_tween()
	var original_scale := head.scale
	tween.tween_property(head, "scale:y", original_scale.y * 0.9, 0.05)
	tween.tween_property(head, "scale:y", original_scale.y, 0.05)

## Start staring at a target (player camera)
func start_staring(target: Node3D) -> void:
	is_staring = true
	stare_target = target
	print("[Clerk] Started staring...")

## Stop staring and return to idle
func stop_staring() -> void:
	is_staring = false
	stare_target = null
	
	# Return head to original position
	if head:
		var tween := create_tween()
		tween.tween_property(head, "rotation", head_original_rotation, 0.5)

## Enable creepy mode (slower, more unsettling movements)
func set_creepy_mode(enabled: bool) -> void:
	creepy_mode = enabled

## Do a sudden head snap towards player
func creepy_head_snap(target: Node3D) -> void:
	if not head or not animations_enabled:
		return
	
	var target_pos := target.global_position
	var head_pos := head.global_position
	var direction := (target_pos - head_pos).normalized()
	
	var target_rotation := Vector3.ZERO
	target_rotation.y = atan2(direction.x, direction.z)
	target_rotation.x = -asin(direction.y)
	
	# Instant snap
	var tween := create_tween()
	tween.tween_property(head, "rotation", target_rotation, 0.05)
	
	# Hold for a moment
	await get_tree().create_timer(2.0).timeout
	
	# Slowly return
	tween = create_tween()
	tween.tween_property(head, "rotation", head_original_rotation, 1.5)

## Do a creepy body twitch
func body_twitch() -> void:
	if not body or not animations_enabled:
		return
	
	var tween := create_tween()
	var twitch := Vector3(randf_range(-0.05, 0.05), 0, randf_range(-0.05, 0.05))
	
	tween.tween_property(body, "position", body_original_position + twitch, 0.02)
	tween.tween_property(body, "position", body_original_position, 0.1)

## Stamp animation
func do_stamp_animation() -> void:
	var stamp: MeshInstance3D = get_node_or_null("Stamp") as MeshInstance3D
	if not stamp:
		return
	
	var original_pos: Vector3 = stamp.position
	var tween := create_tween()
	
	# Lift stamp
	tween.tween_property(stamp, "position:y", original_pos.y + 0.2, 0.15)
	# Slam down
	tween.tween_property(stamp, "position:y", original_pos.y - 0.05, 0.05)
	# Return
	tween.tween_property(stamp, "position:y", original_pos.y, 0.1)

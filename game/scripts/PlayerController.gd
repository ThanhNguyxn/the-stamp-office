extends CharacterBody3D
## PlayerController - First-person movement with mouse-look
## FIXED: Works inside SubViewport by using Input polling instead of _input()
## Two modes: LOOK_MODE (mouse captured, can walk) and CURSOR_MODE (mouse visible, can click UI)

@export var move_speed: float = 4.0
@export var sprint_speed: float = 7.0
@export var mouse_sensitivity: float = 0.003
@export var gravity: float = 9.8

# Node references
var head: Node3D = null
var camera: Camera3D = null
var debug_label: Label = null

# Mode state
var cursor_mode: bool = false
var desk_focused: bool = false
var saved_transform: Transform3D
var desk_focus_transform: Transform3D

# Pitch limits
const PITCH_MIN: float = -1.4  # ~80 degrees down
const PITCH_MAX: float = 1.4   # ~80 degrees up

# Debug info
var last_input_state: String = ""

func _ready() -> void:
	# Find child nodes
	head = get_node_or_null("Head")
	if head:
		camera = head.get_node_or_null("Camera3D")
		if camera:
			camera.make_current()
	
	# Create debug HUD label
	_create_debug_hud()
	
	# Start in LOOK mode (cursor captured, movement enabled)
	cursor_mode = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	print("[PlayerController] Ready - LOOK mode, WASD enabled")

func _create_debug_hud() -> void:
	# Create a CanvasLayer for debug HUD that overlays everything
	var canvas = CanvasLayer.new()
	canvas.layer = 100
	add_child(canvas)
	
	debug_label = Label.new()
	debug_label.position = Vector2(10, 10)
	debug_label.add_theme_font_size_override("font_size", 12)
	debug_label.add_theme_color_override("font_color", Color(0, 1, 0, 1))
	debug_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
	debug_label.add_theme_constant_override("shadow_offset_x", 1)
	debug_label.add_theme_constant_override("shadow_offset_y", 1)
	canvas.add_child(debug_label)

func _physics_process(delta: float) -> void:
	# Always update debug HUD
	_update_debug_hud()
	
	# Check for mode toggle via Input (works globally)
	if Input.is_action_just_pressed("toggle_cursor"):
		set_cursor_mode(not cursor_mode)
	
	# Check for interact (E) to focus/unfocus desk
	if Input.is_action_just_pressed("interact"):
		focus_desk(not desk_focused)
	
	# Check for escape to unfocus desk
	if Input.is_action_just_pressed("ui_cancel"):
		if desk_focused:
			focus_desk(false)
	
	# Don't move if in cursor mode or desk focused
	if cursor_mode or desk_focused:
		return
	
	# Get movement input (uses global Input - works even in SubViewport)
	var input_dir := Vector2.ZERO
	if Input.is_action_pressed("move_forward"):
		input_dir.y -= 1
	if Input.is_action_pressed("move_back"):
		input_dir.y += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	
	# Store for debug
	last_input_state = "W:%s A:%s S:%s D:%s" % [
		"1" if Input.is_action_pressed("move_forward") else "0",
		"1" if Input.is_action_pressed("move_left") else "0",
		"1" if Input.is_action_pressed("move_back") else "0",
		"1" if Input.is_action_pressed("move_right") else "0"
	]
	
	input_dir = input_dir.normalized()
	
	# Calculate movement direction relative to player facing
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Speed (sprint if holding shift)
	var speed := sprint_speed if Input.is_action_pressed("move_sprint") else move_speed
	
	# Apply movement
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed * 0.5)
		velocity.z = move_toward(velocity.z, 0, speed * 0.5)
	
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0
	
	move_and_slide()

func _update_debug_hud() -> void:
	if not debug_label:
		return
	
	var mode_str = "CURSOR" if cursor_mode else "LOOK"
	var desk_str = " [DESK]" if desk_focused else ""
	var pos = global_position
	var vel = velocity
	
	debug_label.text = """[DEBUG]
Mode: %s%s
Pos: (%.1f, %.1f, %.1f)
Vel: (%.1f, %.1f, %.1f)
Input: %s
Sprint: %s""" % [
		mode_str, desk_str,
		pos.x, pos.y, pos.z,
		vel.x, vel.y, vel.z,
		last_input_state,
		"ON" if Input.is_action_pressed("move_sprint") else "OFF"
	]

## Handle mouse motion - called from Shift.gd since we're in SubViewport
func handle_mouse_motion(relative: Vector2) -> void:
	# Only handle if not in cursor mode and not desk focused
	if cursor_mode or desk_focused:
		return
	
	# Yaw (rotate body left/right)
	rotate_y(-relative.x * mouse_sensitivity)
	
	# Pitch (rotate head up/down)
	if head:
		head.rotate_x(-relative.y * mouse_sensitivity)
		head.rotation.x = clampf(head.rotation.x, PITCH_MIN, PITCH_MAX)

## Set cursor mode (visible mouse for clicking UI)
func set_cursor_mode(enabled: bool) -> void:
	cursor_mode = enabled
	if enabled:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		print("[PlayerController] → CURSOR mode (movement disabled)")
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		print("[PlayerController] → LOOK mode (WASD enabled)")

## Check if currently in cursor mode
func is_cursor_mode() -> bool:
	return cursor_mode

## Check if desk is focused
func is_desk_focused() -> bool:
	return desk_focused

## Focus on desk (snap camera to desk view)
func focus_desk(enabled: bool) -> void:
	if enabled and not desk_focused:
		# Save current transform
		saved_transform = global_transform
		
		# Find desk focus marker or use default position
		var parent = get_parent()
		var desk_focus: Node3D = null
		if parent:
			desk_focus = parent.find_child("DeskFocus", true, false) as Node3D
		
		if desk_focus:
			desk_focus_transform = desk_focus.global_transform
		else:
			# Default: position in front of desk looking at paper
			desk_focus_transform = Transform3D()
			desk_focus_transform.origin = Vector3(0, 1.6, 2.0)
		
		# Teleport to desk focus
		global_transform.origin = desk_focus_transform.origin
		
		# Reset head pitch and body rotation to face desk
		rotation.y = 0
		if head:
			head.rotation.x = -0.3  # Look down at desk slightly
		
		desk_focused = true
		set_cursor_mode(true)
		print("[PlayerController] Focused on desk")
		
	elif not enabled and desk_focused:
		# Restore saved transform
		global_transform = saved_transform
		desk_focused = false
		set_cursor_mode(false)
		print("[PlayerController] Left desk")

## Get the camera node (for external access)
func get_camera() -> Camera3D:
	return camera

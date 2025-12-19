extends CharacterBody3D
## Player - First-person controller with WASD movement and mouse look
## Works inside SubViewport via forwarded mouse motion from Shift.gd

@export var walk_speed: float = 4.0
@export var sprint_speed: float = 6.0
@export var mouse_sensitivity: float = 0.002
@export var gravity: float = 12.0
@export var jump_velocity: float = 4.5

var head: Node3D = null
var camera: Camera3D = null
var debug_label: Label = null

var cursor_mode: bool = false
var desk_focused: bool = false
var saved_position: Vector3
var saved_rotation: float
var spawn_point: Vector3 = Vector3(0, 1.0, 5)

const PITCH_MIN: float = -1.4
const PITCH_MAX: float = 1.4

var last_input: String = ""

func _ready() -> void:
	head = get_node_or_null("Head")
	if head:
		camera = head.get_node_or_null("Camera3D")
		if camera:
			camera.make_current()
	
	spawn_point = global_position
	_create_debug_hud()
	
	# Start in LOOK mode
	cursor_mode = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	print("[Player] Ready - LOOK mode")

func _create_debug_hud() -> void:
	var canvas = CanvasLayer.new()
	canvas.layer = 100
	add_child(canvas)
	
	debug_label = Label.new()
	debug_label.position = Vector2(10, 10)
	debug_label.add_theme_font_size_override("font_size", 14)
	debug_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.3, 1))
	debug_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	debug_label.add_theme_constant_override("shadow_offset_x", 1)
	debug_label.add_theme_constant_override("shadow_offset_y", 1)
	canvas.add_child(debug_label)

func _physics_process(delta: float) -> void:
	# Respawn if fallen
	if global_position.y < -20:
		global_position = spawn_point
		velocity = Vector3.ZERO
	
	_update_debug()
	
	# Mode toggles
	if Input.is_action_just_pressed("toggle_cursor"):
		set_cursor_mode(not cursor_mode)
	
	if Input.is_action_just_pressed("interact_desk"):
		focus_desk(not desk_focused)
	
	# Movement only in LOOK mode
	if cursor_mode or desk_focused:
		if not is_on_floor():
			velocity.y -= gravity * delta
		else:
			velocity.y = 0
		move_and_slide()
		return
	
	var input_dir := Vector2.ZERO
	if Input.is_action_pressed("move_forward"):
		input_dir.y -= 1
	if Input.is_action_pressed("move_back"):
		input_dir.y += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	
	input_dir = input_dir.normalized()
	last_input = "W:%d A:%d S:%d D:%d" % [
		1 if Input.is_action_pressed("move_forward") else 0,
		1 if Input.is_action_pressed("move_left") else 0,
		1 if Input.is_action_pressed("move_back") else 0,
		1 if Input.is_action_pressed("move_right") else 0
	]
	
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var speed := sprint_speed if Input.is_action_pressed("move_sprint") else walk_speed
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed * 0.3)
		velocity.z = move_toward(velocity.z, 0, speed * 0.3)
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0
		if Input.is_action_just_pressed("move_jump"):
			velocity.y = jump_velocity
	
	move_and_slide()

func _update_debug() -> void:
	if not debug_label:
		return
	var mode_str = "CURSOR" if cursor_mode else "LOOK"
	var desk_str = " [DESK]" if desk_focused else ""
	debug_label.text = "Mode: %s%s\nPos: (%.1f, %.1f, %.1f)\nVel: (%.1f, %.1f, %.1f)\nWASD: %s | Sprint: %s" % [
		mode_str, desk_str,
		global_position.x, global_position.y, global_position.z,
		velocity.x, velocity.y, velocity.z,
		last_input,
		"ON" if Input.is_action_pressed("move_sprint") else "OFF"
	]

func handle_mouse_motion(relative: Vector2) -> void:
	if cursor_mode or desk_focused:
		return
	rotate_y(-relative.x * mouse_sensitivity)
	if head:
		head.rotate_x(-relative.y * mouse_sensitivity)
		head.rotation.x = clampf(head.rotation.x, PITCH_MIN, PITCH_MAX)

func set_cursor_mode(enabled: bool) -> void:
	cursor_mode = enabled
	if enabled:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		print("[Player] CURSOR mode")
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		print("[Player] LOOK mode")

func is_cursor_mode() -> bool:
	return cursor_mode

func focus_desk(enabled: bool) -> void:
	if enabled and not desk_focused:
		saved_position = global_position
		saved_rotation = rotation.y
		var desk_focus = get_parent().find_child("DeskFocus", true, false) as Node3D
		if desk_focus:
			global_position = desk_focus.global_position
			rotation.y = 0
			if head:
				head.rotation.x = -0.25
		else:
			global_position = Vector3(0, 1.5, 2.8)
			rotation.y = 0
			if head:
				head.rotation.x = -0.2
		desk_focused = true
		set_cursor_mode(true)
		print("[Player] Desk focused")
	elif not enabled and desk_focused:
		global_position = saved_position
		rotation.y = saved_rotation
		if head:
			head.rotation.x = 0
		desk_focused = false
		set_cursor_mode(false)
		print("[Player] Left desk")

func get_camera() -> Camera3D:
	return camera

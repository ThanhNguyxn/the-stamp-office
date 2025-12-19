extends CharacterBody3D
## PlayerController - First-person movement with mouse-look
## Two modes: LOOK_MODE (mouse captured, can walk) and CURSOR_MODE (mouse visible, can click UI)

@export var move_speed: float = 4.0
@export var sprint_speed: float = 7.0
@export var mouse_sensitivity: float = 0.002
@export var gravity: float = 9.8

# Node references
var head: Node3D = null
var camera: Camera3D = null

# Mode state
var cursor_mode: bool = false
var desk_focused: bool = false
var saved_transform: Transform3D
var desk_focus_transform: Transform3D

# Pitch limits
const PITCH_MIN: float = -1.4  # ~80 degrees down
const PITCH_MAX: float = 1.4   # ~80 degrees up

func _ready() -> void:
	# Find child nodes
	head = get_node_or_null("Head")
	if head:
		camera = head.get_node_or_null("Camera3D")
	
	# Start in look mode (cursor captured)
	set_cursor_mode(false)

func _input(event: InputEvent) -> void:
	# Toggle cursor mode with Tab
	if event.is_action_pressed("toggle_cursor"):
		set_cursor_mode(not cursor_mode)
		return
	
	# Leave desk focus with Escape
	if event.is_action_pressed("ui_cancel"):
		if desk_focused:
			focus_desk(false)
		return
	
	# Interact with E (toggle desk focus)
	if event.is_action_pressed("interact"):
		focus_desk(not desk_focused)
		return
	
	# Mouse look (only in look mode and not desk focused)
	if event is InputEventMouseMotion and not cursor_mode and not desk_focused:
		var motion = event as InputEventMouseMotion
		
		# Yaw (rotate body left/right)
		rotate_y(-motion.relative.x * mouse_sensitivity)
		
		# Pitch (rotate head up/down)
		if head:
			head.rotate_x(-motion.relative.y * mouse_sensitivity)
			head.rotation.x = clampf(head.rotation.x, PITCH_MIN, PITCH_MAX)

func _physics_process(delta: float) -> void:
	# Don't move if in cursor mode or desk focused
	if cursor_mode or desk_focused:
		return
	
	# Get movement input
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
	
	# Calculate movement direction relative to player facing
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Speed (sprint if holding shift)
	var speed := sprint_speed if Input.is_action_pressed("move_sprint") else move_speed
	
	# Apply movement
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0
	
	move_and_slide()

## Set cursor mode (visible mouse for clicking UI)
func set_cursor_mode(enabled: bool) -> void:
	cursor_mode = enabled
	if enabled:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

## Check if currently in cursor mode
func is_cursor_mode() -> bool:
	return cursor_mode

## Focus on desk (snap camera to desk view)
func focus_desk(enabled: bool) -> void:
	if enabled and not desk_focused:
		# Save current transform
		saved_transform = global_transform
		
		# Find desk focus marker or use default position
		var desk_focus = get_parent().find_child("DeskFocus", true, false) as Node3D
		if desk_focus:
			desk_focus_transform = desk_focus.global_transform
		else:
			# Default: position in front of desk looking at paper
			desk_focus_transform = Transform3D()
			desk_focus_transform.origin = Vector3(0, 1.6, 2.0)
			desk_focus_transform = desk_focus_transform.looking_at(Vector3(0, 0.8, 0.8), Vector3.UP)
		
		# Teleport to desk focus
		global_transform.origin = desk_focus_transform.origin
		
		# Reset head pitch and body rotation to face desk
		rotation.y = desk_focus_transform.basis.get_euler().y
		if head:
			head.rotation.x = desk_focus_transform.basis.get_euler().x
		
		desk_focused = true
		set_cursor_mode(true)
		
	elif not enabled and desk_focused:
		# Restore saved transform
		global_transform = saved_transform
		desk_focused = false
		set_cursor_mode(false)

## Get the camera node (for external access)
func get_camera() -> Camera3D:
	return camera

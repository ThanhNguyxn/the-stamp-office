extends CharacterBody3D
## Player - First-person controller with WASD movement and mouse look
## E = interact with objects (desk, doors, items), Tab = toggle cursor, Esc = back

@export var walk_speed: float = 4.5
@export var sprint_speed: float = 7.0
@export var mouse_sensitivity: float = 0.002
@export var gravity: float = 12.0
@export var jump_velocity: float = 4.5
@export var interact_distance: float = 3.0

# Head bob settings
@export var head_bob_enabled: bool = true
@export var head_bob_frequency: float = 2.4
@export var head_bob_amplitude: float = 0.06
@export var head_bob_sway: float = 0.03

var head: Node3D = null
var camera: Camera3D = null
var debug_label: Label = null
var interact_hint_label: Label = null

# Body parts for presence
var player_body: Node3D = null
var left_arm: MeshInstance3D = null
var right_arm: MeshInstance3D = null

var cursor_mode: bool = false
var desk_focused: bool = false
var saved_position: Vector3
var saved_rotation: float
var saved_head_pitch: float
var spawn_point: Vector3 = Vector3(0, 1.0, 5)

# Interaction system
var current_interactable: Node = null
var interact_hint: String = ""

# Head bob state
var head_bob_time: float = 0.0
var default_head_y: float = 0.0
var is_moving: bool = false
var footstep_timer: float = 0.0

const PITCH_MIN: float = -1.4
const PITCH_MAX: float = 1.4

var last_input: String = ""

signal interacted_with(object_name: String, object: Node)
signal entered_area(area_name: String)
signal footstep()

func _ready() -> void:
	head = get_node_or_null("Head")
	if head:
		camera = head.get_node_or_null("Camera3D")
		if camera:
			camera.make_current()
		default_head_y = head.position.y
	
	spawn_point = global_position
	_create_debug_hud()
	_create_interact_hint()
	_create_player_body()
	
	cursor_mode = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	print("[Player] Ready - LOOK mode | E=interact Tab=cursor")

func _create_debug_hud() -> void:
	var canvas = CanvasLayer.new()
	canvas.name = "DebugHUD"
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

func _create_interact_hint() -> void:
	var canvas = get_node_or_null("DebugHUD")
	if not canvas:
		return
	
	interact_hint_label = Label.new()
	interact_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	interact_hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	interact_hint_label.add_theme_font_size_override("font_size", 18)
	interact_hint_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.9))
	interact_hint_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	interact_hint_label.add_theme_constant_override("shadow_offset_x", 2)
	interact_hint_label.add_theme_constant_override("shadow_offset_y", 2)
	canvas.add_child(interact_hint_label)

func _create_player_body() -> void:
	# Create visible body parts attached to camera
	if not camera:
		return
	
	player_body = Node3D.new()
	player_body.name = "PlayerBody"
	camera.add_child(player_body)
	
	# Arm material
	var arm_material = StandardMaterial3D.new()
	arm_material.albedo_color = Color(0.85, 0.7, 0.6, 1)  # Skin tone
	arm_material.roughness = 0.8
	
	var sleeve_material = StandardMaterial3D.new()
	sleeve_material.albedo_color = Color(0.2, 0.22, 0.25, 1)  # Dark shirt
	sleeve_material.roughness = 0.7
	
	# Left arm (visible when looking down-left)
	left_arm = MeshInstance3D.new()
	left_arm.name = "LeftArm"
	var left_arm_mesh = BoxMesh.new()
	left_arm_mesh.size = Vector3(0.08, 0.35, 0.08)
	left_arm.mesh = left_arm_mesh
	left_arm.position = Vector3(-0.35, -0.5, -0.3)
	left_arm.rotation_degrees = Vector3(15, 0, 10)
	left_arm.material_override = sleeve_material
	player_body.add_child(left_arm)
	
	# Left hand
	var left_hand = MeshInstance3D.new()
	left_hand.name = "LeftHand"
	var left_hand_mesh = BoxMesh.new()
	left_hand_mesh.size = Vector3(0.07, 0.12, 0.05)
	left_hand.mesh = left_hand_mesh
	left_hand.position = Vector3(0, -0.22, 0)
	left_hand.material_override = arm_material
	left_arm.add_child(left_hand)
	
	# Right arm (visible when looking down-right)
	right_arm = MeshInstance3D.new()
	right_arm.name = "RightArm"
	var right_arm_mesh = BoxMesh.new()
	right_arm_mesh.size = Vector3(0.08, 0.35, 0.08)
	right_arm.mesh = right_arm_mesh
	right_arm.position = Vector3(0.35, -0.5, -0.3)
	right_arm.rotation_degrees = Vector3(15, 0, -10)
	right_arm.material_override = sleeve_material
	player_body.add_child(right_arm)
	
	# Right hand
	var right_hand = MeshInstance3D.new()
	right_hand.name = "RightHand"
	var right_hand_mesh = BoxMesh.new()
	right_hand_mesh.size = Vector3(0.07, 0.12, 0.05)
	right_hand.mesh = right_hand_mesh
	right_hand.position = Vector3(0, -0.22, 0)
	right_hand.material_override = arm_material
	right_arm.add_child(right_hand)
	
	# Torso hint (visible when looking straight down)
	var torso = MeshInstance3D.new()
	torso.name = "Torso"
	var torso_mesh = BoxMesh.new()
	torso_mesh.size = Vector3(0.4, 0.15, 0.25)
	torso.mesh = torso_mesh
	torso.position = Vector3(0, -0.7, -0.1)
	torso.material_override = sleeve_material
	player_body.add_child(torso)
	
	# Legs hint (visible when looking down)
	var legs = MeshInstance3D.new()
	legs.name = "Legs"
	var legs_mesh = BoxMesh.new()
	legs_mesh.size = Vector3(0.35, 0.5, 0.2)
	legs.mesh = legs_mesh
	legs.position = Vector3(0, -1.1, 0.1)
	
	var pants_material = StandardMaterial3D.new()
	pants_material.albedo_color = Color(0.15, 0.15, 0.18, 1)  # Dark pants
	pants_material.roughness = 0.7
	legs.material_override = pants_material
	player_body.add_child(legs)
	
	# Feet
	var feet = MeshInstance3D.new()
	feet.name = "Feet"
	var feet_mesh = BoxMesh.new()
	feet_mesh.size = Vector3(0.35, 0.08, 0.3)
	feet.mesh = feet_mesh
	feet.position = Vector3(0, -1.4, 0.2)
	
	var shoes_material = StandardMaterial3D.new()
	shoes_material.albedo_color = Color(0.1, 0.08, 0.06, 1)  # Dark shoes
	shoes_material.roughness = 0.5
	feet.material_override = shoes_material
	player_body.add_child(feet)

func _apply_head_bob(delta: float, is_sprinting: bool) -> void:
	if not head or not head_bob_enabled or desk_focused:
		return
	
	if is_moving and is_on_floor():
		var freq_mult = 1.4 if is_sprinting else 1.0
		head_bob_time += delta * head_bob_frequency * freq_mult
		
		# Vertical bob
		var bob_y = sin(head_bob_time * TAU) * head_bob_amplitude
		# Horizontal sway
		var bob_x = cos(head_bob_time * TAU * 0.5) * head_bob_sway
		
		head.position.y = default_head_y + bob_y
		head.position.x = bob_x
		
		# Footstep timing (every half cycle)
		footstep_timer += delta * head_bob_frequency * freq_mult
		if footstep_timer >= 0.5:
			footstep_timer = 0.0
			emit_signal("footstep")
	else:
		# Smoothly return to default
		head.position.y = lerp(head.position.y, default_head_y, delta * 10.0)
		head.position.x = lerp(head.position.x, 0.0, delta * 10.0)
		head_bob_time = 0.0

func _physics_process(delta: float) -> void:
	# Respawn if fallen
	if global_position.y < -20:
		global_position = spawn_point
		velocity = Vector3.ZERO
	
	# Raycast for interactables
	_check_interactables()
	_update_debug()
	_update_interact_hint()
	
	# E key - interact with current object or leave desk
	if Input.is_action_just_pressed("interact_desk"):
		if desk_focused:
			focus_desk(false)
		elif current_interactable:
			_interact_with(current_interactable)
	
	# Tab toggles cursor mode (only when NOT at desk)
	if Input.is_action_just_pressed("toggle_cursor") and not desk_focused:
		set_cursor_mode(not cursor_mode)
	
	# Esc leaves desk or exits cursor mode
	if Input.is_action_just_pressed("ui_cancel"):
		if desk_focused:
			focus_desk(false)
		elif cursor_mode:
			set_cursor_mode(false)
	
	# When desk focused, don't move
	if desk_focused:
		velocity = Vector3.ZERO
		return
	
	# Movement only in LOOK mode
	if cursor_mode:
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
	var is_sprinting := Input.is_action_pressed("move_sprint")
	var speed := sprint_speed if is_sprinting else walk_speed
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		is_moving = true
	else:
		velocity.x = move_toward(velocity.x, 0, speed * 0.3)
		velocity.z = move_toward(velocity.z, 0, speed * 0.3)
		is_moving = false
	
	# Apply head bob while moving
	_apply_head_bob(delta, is_sprinting)
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0
		if Input.is_action_just_pressed("move_jump"):
			velocity.y = jump_velocity
	
	move_and_slide()

func _check_interactables() -> void:
	current_interactable = null
	interact_hint = ""
	
	if not camera or desk_focused:
		return
	
	var space_state = get_world_3d().direct_space_state
	var from = camera.global_position
	var to = from + (-camera.global_basis.z) * interact_distance
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	
	var result = space_state.intersect_ray(query)
	if not result:
		return
	
	var hit_obj = result.collider
	
	# Check what we're looking at
	while hit_obj:
		var obj_name = hit_obj.name
		
		# Desk interaction
		if obj_name == "Desk" or obj_name == "DeskCollision":
			current_interactable = hit_obj
			interact_hint = "[E] Sit at desk"
			return
		
		# Door interaction
		if obj_name.begins_with("Door") or hit_obj.is_in_group("door"):
			current_interactable = hit_obj
			var is_open = hit_obj.get_meta("is_open", false)
			interact_hint = "[E] Close door" if is_open else "[E] Open door"
			return
		
		# Generic interactable
		if hit_obj.is_in_group("interactable"):
			current_interactable = hit_obj
			interact_hint = hit_obj.get_meta("interact_hint", "[E] Interact")
			return
		
		# Locked door
		if obj_name.begins_with("LockedDoor") or hit_obj.is_in_group("locked"):
			current_interactable = hit_obj
			interact_hint = "[LOCKED]"
			return
		
		hit_obj = hit_obj.get_parent()

func _interact_with(obj: Node) -> void:
	if not obj:
		return
	
	var obj_name = obj.name
	print("[Player] Interacting with: ", obj_name)
	
	# Desk - sit down
	if obj_name == "Desk" or obj_name == "DeskCollision":
		focus_desk(true)
		return
	
	# Door - toggle open/close
	if obj_name.begins_with("Door") or obj.is_in_group("door"):
		_toggle_door(obj)
		return
	
	# Locked door - show message
	if obj_name.begins_with("LockedDoor") or obj.is_in_group("locked"):
		emit_signal("interacted_with", "locked_door", obj)
		return
	
	# Generic interactable
	if obj.is_in_group("interactable"):
		emit_signal("interacted_with", obj_name, obj)
		return

func _toggle_door(door_node: Node) -> void:
	var is_open = door_node.get_meta("is_open", false)
	var door_mesh: Node3D = null
	
	# Find the door mesh (could be child or the node itself)
	if door_node is MeshInstance3D:
		door_mesh = door_node
	else:
		door_mesh = door_node.get_node_or_null("DoorMesh")
		if not door_mesh:
			door_mesh = door_node.get_node_or_null("Mesh")
		if not door_mesh:
			for child in door_node.get_children():
				if child is MeshInstance3D:
					door_mesh = child
					break
	
	if not door_mesh:
		print("[Player] Could not find door mesh")
		return
	
	# Toggle door rotation
	var tween = create_tween()
	if is_open:
		tween.tween_property(door_mesh, "rotation:y", 0.0, 0.3)
		door_node.set_meta("is_open", false)
	else:
		tween.tween_property(door_mesh, "rotation:y", -PI/2, 0.3)
		door_node.set_meta("is_open", true)
	
	emit_signal("interacted_with", "door", door_node)

func _update_interact_hint() -> void:
	if not interact_hint_label:
		return
	
	interact_hint_label.text = interact_hint
	
	# Center the hint on screen
	var viewport_size = get_viewport().get_visible_rect().size
	interact_hint_label.position = Vector2(
		viewport_size.x / 2 - interact_hint_label.size.x / 2,
		viewport_size.y * 0.6
	)

func _update_debug() -> void:
	if not debug_label:
		return
	var mode_str = "CURSOR" if cursor_mode else "LOOK"
	var desk_str = " [DESK]" if desk_focused else ""
	var look_str = ""
	if current_interactable and not desk_focused:
		look_str = " [→%s]" % current_interactable.name
	
	debug_label.text = "Mode: %s%s%s\nPos: (%.1f, %.1f, %.1f)\nVel: (%.1f, %.1f, %.1f)\nWASD: %s" % [
		mode_str, desk_str, look_str,
		global_position.x, global_position.y, global_position.z,
		velocity.x, velocity.y, velocity.z,
		last_input
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

func is_desk_focused() -> bool:
	return desk_focused

func focus_desk(enabled: bool) -> void:
	if enabled and not desk_focused:
		saved_position = global_position
		saved_rotation = rotation.y
		if head:
			saved_head_pitch = head.rotation.x
		
		velocity = Vector3.ZERO
		
		# Sit at desk position
		global_position = Vector3(0, 0.45, 2.5)
		rotation.y = 0
		if head:
			head.rotation.x = 0.0
		
		desk_focused = true
		set_cursor_mode(true)
		print("[Player] Desk focused - E or Esc to leave")
		
	elif not enabled and desk_focused:
		velocity = Vector3.ZERO
		global_position = saved_position
		rotation.y = saved_rotation
		if head:
			head.rotation.x = saved_head_pitch
		desk_focused = false
		set_cursor_mode(false)
		print("[Player] Left desk")

func get_camera() -> Camera3D:
	return camera

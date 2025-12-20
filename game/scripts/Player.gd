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
	# Create visible body parts attached to camera - realistic shapes
	if not camera:
		return
	
	player_body = Node3D.new()
	player_body.name = "PlayerBody"
	camera.add_child(player_body)
	
	# ===== MATERIALS =====
	var skin_material = StandardMaterial3D.new()
	skin_material.albedo_color = Color(0.92, 0.78, 0.68, 1)
	skin_material.roughness = 0.85
	
	var shirt_material = StandardMaterial3D.new()
	shirt_material.albedo_color = Color(0.22, 0.24, 0.28, 1)  # Dark gray shirt
	shirt_material.roughness = 0.75
	
	var pants_material = StandardMaterial3D.new()
	pants_material.albedo_color = Color(0.15, 0.15, 0.18, 1)  # Dark pants
	pants_material.roughness = 0.7
	
	var shoes_material = StandardMaterial3D.new()
	shoes_material.albedo_color = Color(0.1, 0.08, 0.06, 1)
	shoes_material.roughness = 0.5
	shoes_material.metallic = 0.15
	
	var belt_material = StandardMaterial3D.new()
	belt_material.albedo_color = Color(0.12, 0.1, 0.08, 1)
	belt_material.roughness = 0.4
	belt_material.metallic = 0.3
	
	# ===== LEFT ARM (cylindrical, realistic) =====
	left_arm = Node3D.new()
	left_arm.name = "LeftArm"
	left_arm.position = Vector3(-0.32, -0.2, -0.3)
	left_arm.rotation_degrees = Vector3(55, 18, 12)
	player_body.add_child(left_arm)
	
	# Upper arm (cylinder)
	var left_upper_arm = MeshInstance3D.new()
	var left_upper_mesh = CylinderMesh.new()
	left_upper_mesh.top_radius = 0.045
	left_upper_mesh.bottom_radius = 0.055
	left_upper_mesh.height = 0.28
	left_upper_arm.mesh = left_upper_mesh
	left_upper_arm.material_override = shirt_material
	left_arm.add_child(left_upper_arm)
	
	# Left forearm
	var left_forearm = Node3D.new()
	left_forearm.name = "LeftForearm"
	left_forearm.position = Vector3(0, -0.2, 0.05)
	left_forearm.rotation_degrees = Vector3(-40, 0, 0)
	left_arm.add_child(left_forearm)
	
	var left_forearm_mesh_inst = MeshInstance3D.new()
	var left_forearm_mesh = CylinderMesh.new()
	left_forearm_mesh.top_radius = 0.035
	left_forearm_mesh.bottom_radius = 0.045
	left_forearm_mesh.height = 0.24
	left_forearm_mesh_inst.mesh = left_forearm_mesh
	left_forearm_mesh_inst.material_override = shirt_material
	left_forearm.add_child(left_forearm_mesh_inst)
	
	# Left wrist (skin visible)
	var left_wrist = MeshInstance3D.new()
	var left_wrist_mesh = CylinderMesh.new()
	left_wrist_mesh.top_radius = 0.028
	left_wrist_mesh.bottom_radius = 0.032
	left_wrist_mesh.height = 0.06
	left_wrist.mesh = left_wrist_mesh
	left_wrist.position = Vector3(0, -0.15, 0)
	left_wrist.material_override = skin_material
	left_forearm.add_child(left_wrist)
	
	# Left hand (capsule-like)
	var left_hand = MeshInstance3D.new()
	var left_hand_mesh = CapsuleMesh.new()
	left_hand_mesh.radius = 0.032
	left_hand_mesh.height = 0.12
	left_hand.mesh = left_hand_mesh
	left_hand.position = Vector3(0, -0.22, 0.02)
	left_hand.rotation_degrees = Vector3(15, 0, 0)
	left_hand.material_override = skin_material
	left_forearm.add_child(left_hand)
	
	# Left fingers (simple cylinders)
	for i in range(4):
		var finger = MeshInstance3D.new()
		var finger_mesh = CylinderMesh.new()
		finger_mesh.top_radius = 0.006
		finger_mesh.bottom_radius = 0.008
		finger_mesh.height = 0.04
		finger.mesh = finger_mesh
		finger.position = Vector3(-0.018 + i * 0.012, -0.28, 0.03)
		finger.rotation_degrees = Vector3(20, 0, 0)
		finger.material_override = skin_material
		left_forearm.add_child(finger)
	
	# Left thumb
	var left_thumb = MeshInstance3D.new()
	var left_thumb_mesh = CylinderMesh.new()
	left_thumb_mesh.top_radius = 0.008
	left_thumb_mesh.bottom_radius = 0.01
	left_thumb_mesh.height = 0.035
	left_thumb.mesh = left_thumb_mesh
	left_thumb.position = Vector3(-0.035, -0.2, 0.02)
	left_thumb.rotation_degrees = Vector3(0, 0, 45)
	left_thumb.material_override = skin_material
	left_forearm.add_child(left_thumb)
	
	# ===== RIGHT ARM (mirror of left) =====
	right_arm = Node3D.new()
	right_arm.name = "RightArm"
	right_arm.position = Vector3(0.32, -0.2, -0.3)
	right_arm.rotation_degrees = Vector3(55, -18, -12)
	player_body.add_child(right_arm)
	
	# Upper arm
	var right_upper_arm = MeshInstance3D.new()
	var right_upper_mesh = CylinderMesh.new()
	right_upper_mesh.top_radius = 0.045
	right_upper_mesh.bottom_radius = 0.055
	right_upper_mesh.height = 0.28
	right_upper_arm.mesh = right_upper_mesh
	right_upper_arm.material_override = shirt_material
	right_arm.add_child(right_upper_arm)
	
	# Right forearm
	var right_forearm = Node3D.new()
	right_forearm.name = "RightForearm"
	right_forearm.position = Vector3(0, -0.2, 0.05)
	right_forearm.rotation_degrees = Vector3(-40, 0, 0)
	right_arm.add_child(right_forearm)
	
	var right_forearm_mesh_inst = MeshInstance3D.new()
	var right_forearm_mesh = CylinderMesh.new()
	right_forearm_mesh.top_radius = 0.035
	right_forearm_mesh.bottom_radius = 0.045
	right_forearm_mesh.height = 0.24
	right_forearm_mesh_inst.mesh = right_forearm_mesh
	right_forearm_mesh_inst.material_override = shirt_material
	right_forearm.add_child(right_forearm_mesh_inst)
	
	# Right wrist
	var right_wrist = MeshInstance3D.new()
	var right_wrist_mesh = CylinderMesh.new()
	right_wrist_mesh.top_radius = 0.028
	right_wrist_mesh.bottom_radius = 0.032
	right_wrist_mesh.height = 0.06
	right_wrist.mesh = right_wrist_mesh
	right_wrist.position = Vector3(0, -0.15, 0)
	right_wrist.material_override = skin_material
	right_forearm.add_child(right_wrist)
	
	# Right hand
	var right_hand = MeshInstance3D.new()
	var right_hand_mesh = CapsuleMesh.new()
	right_hand_mesh.radius = 0.032
	right_hand_mesh.height = 0.12
	right_hand.mesh = right_hand_mesh
	right_hand.position = Vector3(0, -0.22, 0.02)
	right_hand.rotation_degrees = Vector3(15, 0, 0)
	right_hand.material_override = skin_material
	right_forearm.add_child(right_hand)
	
	# Right fingers
	for i in range(4):
		var finger = MeshInstance3D.new()
		var finger_mesh = CylinderMesh.new()
		finger_mesh.top_radius = 0.006
		finger_mesh.bottom_radius = 0.008
		finger_mesh.height = 0.04
		finger.mesh = finger_mesh
		finger.position = Vector3(-0.018 + i * 0.012, -0.28, 0.03)
		finger.rotation_degrees = Vector3(20, 0, 0)
		finger.material_override = skin_material
		right_forearm.add_child(finger)
	
	# Right thumb
	var right_thumb = MeshInstance3D.new()
	var right_thumb_mesh = CylinderMesh.new()
	right_thumb_mesh.top_radius = 0.008
	right_thumb_mesh.bottom_radius = 0.01
	right_thumb_mesh.height = 0.035
	right_thumb.mesh = right_thumb_mesh
	right_thumb.position = Vector3(0.035, -0.2, 0.02)
	right_thumb.rotation_degrees = Vector3(0, 0, -45)
	right_thumb.material_override = skin_material
	right_forearm.add_child(right_thumb)
	
	# ===== TORSO (visible when looking down) =====
	var torso = Node3D.new()
	torso.name = "Torso"
	torso.position = Vector3(0, -0.45, 0.05)
	player_body.add_child(torso)
	
	# Chest (capsule)
	var chest = MeshInstance3D.new()
	var chest_mesh = CapsuleMesh.new()
	chest_mesh.radius = 0.2
	chest_mesh.height = 0.35
	chest.mesh = chest_mesh
	chest.material_override = shirt_material
	torso.add_child(chest)
	
	# Belt
	var belt = MeshInstance3D.new()
	var belt_mesh = CylinderMesh.new()
	belt_mesh.top_radius = 0.18
	belt_mesh.bottom_radius = 0.18
	belt_mesh.height = 0.05
	belt.mesh = belt_mesh
	belt.position = Vector3(0, -0.22, 0)
	belt.material_override = belt_material
	torso.add_child(belt)
	
	# Belt buckle
	var buckle = MeshInstance3D.new()
	var buckle_mesh = BoxMesh.new()
	buckle_mesh.size = Vector3(0.04, 0.035, 0.015)
	buckle.mesh = buckle_mesh
	buckle.position = Vector3(0, -0.22, 0.18)
	var buckle_mat = StandardMaterial3D.new()
	buckle_mat.albedo_color = Color(0.7, 0.65, 0.5, 1)
	buckle_mat.metallic = 0.9
	buckle_mat.roughness = 0.2
	buckle.material_override = buckle_mat
	torso.add_child(buckle)
	
	# ===== LEGS (cylindrical) =====
	# Left thigh
	var left_thigh = MeshInstance3D.new()
	var left_thigh_mesh = CylinderMesh.new()
	left_thigh_mesh.top_radius = 0.09
	left_thigh_mesh.bottom_radius = 0.07
	left_thigh_mesh.height = 0.4
	left_thigh.mesh = left_thigh_mesh
	left_thigh.position = Vector3(-0.1, -0.95, 0.15)
	left_thigh.material_override = pants_material
	player_body.add_child(left_thigh)
	
	# Left shin
	var left_shin = MeshInstance3D.new()
	var left_shin_mesh = CylinderMesh.new()
	left_shin_mesh.top_radius = 0.065
	left_shin_mesh.bottom_radius = 0.05
	left_shin_mesh.height = 0.38
	left_shin.mesh = left_shin_mesh
	left_shin.position = Vector3(-0.1, -1.35, 0.18)
	left_shin.material_override = pants_material
	player_body.add_child(left_shin)
	
	# Right thigh
	var right_thigh = MeshInstance3D.new()
	var right_thigh_mesh = CylinderMesh.new()
	right_thigh_mesh.top_radius = 0.09
	right_thigh_mesh.bottom_radius = 0.07
	right_thigh_mesh.height = 0.4
	right_thigh.mesh = right_thigh_mesh
	right_thigh.position = Vector3(0.1, -0.95, 0.15)
	right_thigh.material_override = pants_material
	player_body.add_child(right_thigh)
	
	# Right shin
	var right_shin = MeshInstance3D.new()
	var right_shin_mesh = CylinderMesh.new()
	right_shin_mesh.top_radius = 0.065
	right_shin_mesh.bottom_radius = 0.05
	right_shin_mesh.height = 0.38
	right_shin.mesh = right_shin_mesh
	right_shin.position = Vector3(0.1, -1.35, 0.18)
	right_shin.material_override = pants_material
	player_body.add_child(right_shin)
	
	# ===== FEET (rounded shoes) =====
	# Left foot
	var left_foot = Node3D.new()
	left_foot.name = "LeftFoot"
	left_foot.position = Vector3(-0.1, -1.55, 0.28)
	player_body.add_child(left_foot)
	
	var left_shoe_back = MeshInstance3D.new()
	var left_shoe_back_mesh = CapsuleMesh.new()
	left_shoe_back_mesh.radius = 0.05
	left_shoe_back_mesh.height = 0.12
	left_shoe_back.mesh = left_shoe_back_mesh
	left_shoe_back.rotation_degrees = Vector3(90, 0, 0)
	left_shoe_back.position = Vector3(0, 0, -0.03)
	left_shoe_back.material_override = shoes_material
	left_foot.add_child(left_shoe_back)
	
	var left_shoe_front = MeshInstance3D.new()
	var left_shoe_front_mesh = CapsuleMesh.new()
	left_shoe_front_mesh.radius = 0.045
	left_shoe_front_mesh.height = 0.14
	left_shoe_front.mesh = left_shoe_front_mesh
	left_shoe_front.rotation_degrees = Vector3(90, 0, 0)
	left_shoe_front.position = Vector3(0, -0.01, 0.08)
	left_shoe_front.material_override = shoes_material
	left_foot.add_child(left_shoe_front)
	
	# Right foot
	var right_foot = Node3D.new()
	right_foot.name = "RightFoot"
	right_foot.position = Vector3(0.1, -1.55, 0.28)
	player_body.add_child(right_foot)
	
	var right_shoe_back = MeshInstance3D.new()
	var right_shoe_back_mesh = CapsuleMesh.new()
	right_shoe_back_mesh.radius = 0.05
	right_shoe_back_mesh.height = 0.12
	right_shoe_back.mesh = right_shoe_back_mesh
	right_shoe_back.rotation_degrees = Vector3(90, 0, 0)
	right_shoe_back.position = Vector3(0, 0, -0.03)
	right_shoe_back.material_override = shoes_material
	right_foot.add_child(right_shoe_back)
	
	var right_shoe_front = MeshInstance3D.new()
	var right_shoe_front_mesh = CapsuleMesh.new()
	right_shoe_front_mesh.radius = 0.045
	right_shoe_front_mesh.height = 0.14
	right_shoe_front.mesh = right_shoe_front_mesh
	right_shoe_front.rotation_degrees = Vector3(90, 0, 0)
	right_shoe_front.position = Vector3(0, -0.01, 0.08)
	right_shoe_front.material_override = shoes_material
	right_foot.add_child(right_shoe_front)
	
	# Create footstep audio player
	_create_footstep_audio()

func _create_footstep_audio() -> void:
	var audio_player = AudioStreamPlayer.new()
	audio_player.name = "FootstepPlayer"
	audio_player.volume_db = -8.0
	add_child(audio_player)
	
	# Generate procedural footstep sound
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = 22050
	generator.buffer_length = 0.1
	audio_player.stream = generator
	
	# Connect footstep signal
	footstep.connect(_play_footstep)

func _play_footstep() -> void:
	var audio_player = get_node_or_null("FootstepPlayer")
	if not audio_player:
		return
	
	# Create a simple thud sound procedurally
	var playback = audio_player.get_stream_playback()
	if playback:
		var frames_available = playback.get_frames_available()
		for i in range(frames_available):
			var t = float(i) / 22050.0
			# Simple thud: decaying noise burst
			var noise = randf_range(-1.0, 1.0)
			var envelope = exp(-t * 80.0)  # Quick decay
			var sample = noise * envelope * 0.3
			playback.push_frame(Vector2(sample, sample))
		audio_player.play()

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
		
		# Arm sway - arms swing opposite to each other (natural walking motion)
		if left_arm and right_arm:
			var arm_swing = sin(head_bob_time * TAU) * 0.12
			# Base rotation is 55 degrees (from _create_player_body)
			left_arm.rotation.x = deg_to_rad(55) + arm_swing
			right_arm.rotation.x = deg_to_rad(55) - arm_swing
			
			# Slight up/down and forward/back motion
			left_arm.position.y = -0.2 + sin(head_bob_time * TAU) * 0.015
			right_arm.position.y = -0.2 - sin(head_bob_time * TAU) * 0.015
			left_arm.position.z = -0.3 + cos(head_bob_time * TAU) * 0.02
			right_arm.position.z = -0.3 - cos(head_bob_time * TAU) * 0.02
		
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
		
		# Reset arm positions
		if left_arm and right_arm:
			left_arm.rotation.x = lerp(left_arm.rotation.x, deg_to_rad(55), delta * 8.0)
			right_arm.rotation.x = lerp(right_arm.rotation.x, deg_to_rad(55), delta * 8.0)
			left_arm.position.y = lerp(left_arm.position.y, -0.2, delta * 8.0)
			right_arm.position.y = lerp(right_arm.position.y, -0.2, delta * 8.0)
			left_arm.position.z = lerp(left_arm.position.z, -0.3, delta * 8.0)
			right_arm.position.z = lerp(right_arm.position.z, -0.3, delta * 8.0)

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

extends Control
## Shift - Desk job workflow with story integration and endings
## World-space paper UI, first-person movement, secret stamp logic

# Paper viewport
@onready var paper_viewport: SubViewport = $PaperViewport

# UI elements
@onready var paper_ui: Control = $PaperViewport/PaperUI
@onready var paper_background: ColorRect = $PaperViewport/PaperUI/Background
@onready var vbox: VBoxContainer = $PaperViewport/PaperUI/VBox
@onready var header: Label = $PaperViewport/PaperUI/VBox/HeaderRow/Header
@onready var rulebook_button: Button = $PaperViewport/PaperUI/VBox/HeaderRow/RulebookButton
@onready var ticket_panel: PanelContainer = $PaperViewport/PaperUI/VBox/TicketPanel
@onready var ticket_vbox: VBoxContainer = $PaperViewport/PaperUI/VBox/TicketPanel/TicketVBox
@onready var ticket_text: Label = $PaperViewport/PaperUI/VBox/TicketPanel/TicketVBox/TicketText
@onready var attachment: Label = $PaperViewport/PaperUI/VBox/TicketPanel/TicketVBox/Attachment
@onready var stamp_buttons: VBoxContainer = $PaperViewport/PaperUI/VBox/StampButtons
@onready var mood_value: Label = $PaperViewport/PaperUI/VBox/MetersBox/MoodValue
@onready var contradiction_value: Label = $PaperViewport/PaperUI/VBox/MetersBox/ContradictionValue
@onready var back_button: Button = $PaperViewport/PaperUI/VBox/BackButton

# Workflow buttons
@onready var open_folder_btn: Button = $PaperViewport/PaperUI/VBox/WorkflowBar/OpenFolderBtn
@onready var inspect_btn: Button = $PaperViewport/PaperUI/VBox/WorkflowBar/InspectBtn
@onready var check_rules_btn: Button = $PaperViewport/PaperUI/VBox/WorkflowBar/CheckRulesBtn
@onready var file_ticket_btn: Button = $PaperViewport/PaperUI/VBox/WorkflowBar/FileTicketBtn

# Popups
@onready var rulebook_popup: PanelContainer = $PaperViewport/PaperUI/RulebookPopup
@onready var rules_text: Label = $PaperViewport/PaperUI/RulebookPopup/VBox/Scroll/RulesText
@onready var rulebook_close_button: Button = $PaperViewport/PaperUI/RulebookPopup/VBox/RulebookCloseButton
@onready var event_overlay: PanelContainer = $PaperViewport/PaperUI/EventOverlay
@onready var event_title: Label = $PaperViewport/PaperUI/EventOverlay/VBox/EventTitle
@onready var event_body: Label = $PaperViewport/PaperUI/EventOverlay/VBox/EventBody
@onready var choice_a_btn: Button = $PaperViewport/PaperUI/EventOverlay/VBox/ButtonBox/ChoiceA
@onready var choice_b_btn: Button = $PaperViewport/PaperUI/EventOverlay/VBox/ButtonBox/ChoiceB

# HUD
@onready var toast: Label = $BottomHUD/VBox/Toast
@onready var progress: Label = $BottomHUD/VBox/Progress
@onready var scanline_overlay: ColorRect = $ScanlineOverlay
@onready var sfx: Node = $Sfx
@onready var shift_events: Node = $ShiftEvents

# Horror system
var horror_events: Node = null

# 3D office
@onready var office_viewport: SubViewport = $OfficeViewportContainer/OfficeViewport
var office_3d: Node3D = null
var paper_screen: MeshInstance3D = null
var paper_area: Area3D = null
var camera_3d: Camera3D = null
var player: CharacterBody3D = null

# Story
var story_director: Node = null

# State
var raycast_ready: bool = false
var shift_number: int = 1
var tickets: Array = []
var index: int = 0
var mood: int = 0
var contradiction: int = 0
var busy: bool = false
var event_active: bool = false
var original_paper_color: Color = Color(0.95, 0.93, 0.88)

# Settings
var vfx_intensity: float = 1.0
var reduce_motion: bool = false
var events_enabled: bool = true

# Workflow
var folder_opened: bool = false
var attachment_inspected: bool = false
var rules_checked: bool = false
var ticket_filed: bool = false
var requires_inspect: bool = false
var requires_rules: bool = false
var current_allowed_stamps: Array = []
var current_ticket_text: String = ""

# Secret stamp targets
const SECRET_TARGETS = [
	"Requesting proof The Office exists.",
	"Requesting acknowledgment of the void.",
	"Requesting exit. Any exit."
]

func _ready() -> void:
	# Get 3D references
	if is_instance_valid(office_viewport) and office_viewport.get_child_count() > 0:
		office_3d = office_viewport.get_child(0) as Node3D
		if is_instance_valid(office_3d):
			player = office_3d.find_child("Player", true, false) as CharacterBody3D
			camera_3d = office_3d.find_child("Camera3D", true, false) as Camera3D
			# Find monitor screen to render UI on
			var monitor = office_3d.find_child("Monitor", true, false) as Node3D
			if is_instance_valid(monitor):
				paper_screen = monitor.get_node_or_null("Screen") as MeshInstance3D
				if is_instance_valid(paper_screen):
					paper_area = paper_screen.get_node_or_null("PaperArea") as Area3D
	
	# Create story director
	story_director = Node.new()
	story_director.set_script(load("res://scripts/StoryDirector.gd"))
	story_director.name = "StoryDirector"
	add_child(story_director)
	if story_director.has_signal("story_message"):
		story_director.connect("story_message", _on_story_message)
	if story_director.has_signal("trigger_horror"):
		story_director.connect("trigger_horror", _on_story_horror)
	
	# Create horror events system
	_setup_horror_events()
	
	_ensure_viewport_3d_capable()
	_setup_paper_texture()
	_apply_settings()
	
	# Wire buttons
	if back_button:
		back_button.pressed.connect(_back)
	if rulebook_button:
		rulebook_button.pressed.connect(_open_rulebook)
	if rulebook_close_button:
		rulebook_close_button.pressed.connect(_close_rulebook)
	if open_folder_btn:
		open_folder_btn.pressed.connect(_on_open_folder)
	if inspect_btn:
		inspect_btn.pressed.connect(_on_inspect)
	if check_rules_btn:
		check_rules_btn.pressed.connect(_on_check_rules)
	if file_ticket_btn:
		file_ticket_btn.pressed.connect(_on_file_ticket)
	if choice_a_btn:
		choice_a_btn.pressed.connect(_on_event_choice_a)
	if choice_b_btn:
		choice_b_btn.pressed.connect(_on_event_choice_b)
	
	# Wire events
	if shift_events:
		if shift_events.has_signal("event_started"):
			shift_events.connect("event_started", _on_event_started)
		if shift_events.has_signal("event_ended"):
			shift_events.connect("event_ended", _on_event_ended)
	
	if event_overlay:
		event_overlay.visible = false
	
	# Get shift number
	var gamestate = get_node_or_null("/root/GameState")
	if gamestate and "selected_shift" in gamestate:
		shift_number = int(gamestate.selected_shift)
	
	if header:
		header.text = "SHIFT %02d" % shift_number
	
	# Set story shift
	if story_director and story_director.has_method("set_shift"):
		story_director.set_shift(shift_number)
	
	# Unlock secret stamp in shift 8
	if shift_number >= 8:
		var save_node = _get_save()
		if save_node and save_node.has_method("unlock_secret_stamp"):
			save_node.unlock_secret_stamp()
	
	# Load tickets
	var dataloader = get_node_or_null("/root/DataLoader")
	if dataloader and dataloader.has_method("load_shift"):
		tickets = dataloader.load_shift(shift_number)
	
	_populate_rulebook()
	
	if tickets.size() > 0:
		_show(0)
		if shift_events and events_enabled and shift_events.has_method("start"):
			shift_events.start()
	else:
		if ticket_text:
			ticket_text.text = "No tickets found"
		if attachment:
			attachment.text = "Run: python tools/sync_game_data.py"
		_update_workflow_ui()
	
	# Show story start message
	if story_director and story_director.has_method("on_shift_start"):
		story_director.on_shift_start()
	
	# Show controls
	await get_tree().create_timer(3.0).timeout
	if toast:
		toast.text = "🎮 WASD move • Mouse look • Tab cursor • E desk • Esc menu"
	
	# Wait for viewport
	await get_tree().process_frame
	await get_tree().process_frame
	raycast_ready = true

func _on_story_message(text: String, _is_intercom: bool) -> void:
	if toast:
		toast.text = text

func _is_cursor_mode() -> bool:
	if player and player.has_method("is_cursor_mode"):
		return player.is_cursor_mode()
	return false

func _ensure_viewport_3d_capable() -> void:
	if is_instance_valid(office_viewport):
		office_viewport.own_world_3d = true

func _get_space_state_3d() -> PhysicsDirectSpaceState3D:
	if is_instance_valid(office_viewport):
		var world: World3D = office_viewport.get_world_3d()
		if is_instance_valid(world):
			var space = world.direct_space_state
			if is_instance_valid(space):
				return space
	if is_instance_valid(camera_3d):
		var cam_viewport = camera_3d.get_viewport()
		if is_instance_valid(cam_viewport):
			var world: World3D = cam_viewport.get_world_3d()
			if is_instance_valid(world):
				var space = world.direct_space_state
				if is_instance_valid(space):
					return space
	return null

func _setup_paper_texture() -> void:
	if not is_instance_valid(paper_viewport) or not is_instance_valid(paper_screen):
		return
	var mat = StandardMaterial3D.new()
	mat.albedo_texture = paper_viewport.get_texture()
	mat.emission_enabled = true
	mat.emission = Color(1, 1, 1, 1)
	mat.emission_energy_multiplier = 0.6
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	paper_screen.material_override = mat

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if player and player.has_method("handle_mouse_motion"):
			var motion = event as InputEventMouseMotion
			player.handle_mouse_motion(motion.relative)
		if _is_cursor_mode():
			_handle_paper_mouse(event)
		return
	
	if event is InputEventMouseButton:
		if _is_cursor_mode():
			_handle_paper_mouse(event)
		return

func _handle_paper_mouse(event: InputEvent) -> void:
	if not event is InputEventMouse:
		return
	if not is_instance_valid(paper_viewport):
		return
	
	var mouse_event = event as InputEventMouse
	var vp_pos: Vector2
	
	# Check if player is at desk (top-down view) - use simple screen mapping
	var is_at_desk = player and player.has_method("is_desk_focused") and player.is_desk_focused()
	
	if is_at_desk:
		# Direct screen-to-viewport mapping for desk mode
		# Paper takes center portion of screen
		var screen_size = get_viewport().get_visible_rect().size
		var paper_rect = Rect2(
			screen_size.x * 0.2,  # left margin 20%
			screen_size.y * 0.15,  # top margin 15%
			screen_size.x * 0.6,  # width 60%
			screen_size.y * 0.7   # height 70%
		)
		
		# Check if mouse is within paper area
		if paper_rect.has_point(mouse_event.position):
			# Map to viewport coordinates
			var rel_x = (mouse_event.position.x - paper_rect.position.x) / paper_rect.size.x
			var rel_y = (mouse_event.position.y - paper_rect.position.y) / paper_rect.size.y
			vp_pos = Vector2(rel_x * paper_viewport.size.x, rel_y * paper_viewport.size.y)
		else:
			return  # Outside paper area
	else:
		# 3D raycast for free-look cursor mode
		if not raycast_ready:
			return
		if not is_instance_valid(camera_3d) or not is_instance_valid(paper_area):
			return
		if not is_instance_valid(paper_screen):
			return
		
		var space_state = _get_space_state_3d()
		if not is_instance_valid(space_state):
			return
		
		var from = camera_3d.project_ray_origin(mouse_event.position)
		var dir = camera_3d.project_ray_normal(mouse_event.position)
		var to = from + dir * 100.0
		
		var query = PhysicsRayQueryParameters3D.create(from, to)
		query.collide_with_areas = true
		query.collide_with_bodies = false
		var result = space_state.intersect_ray(query)
		
		if result.is_empty() or result.get("collider") != paper_area:
			return
		
		var hit_pos = result.get("position", Vector3.ZERO)
		var local_pos = paper_screen.global_transform.affine_inverse() * hit_pos
		var paper_size = Vector2(1.6, 1.0)
		var uv = Vector2((local_pos.x / paper_size.x) + 0.5, (-local_pos.y / paper_size.y) + 0.5)
		uv = uv.clamp(Vector2.ZERO, Vector2.ONE)
		vp_pos = Vector2(uv.x * paper_viewport.size.x, uv.y * paper_viewport.size.y)
	
	# Create and push event to paper viewport
	var new_event: InputEventMouse
	if event is InputEventMouseButton:
		var btn = InputEventMouseButton.new()
		btn.button_index = (event as InputEventMouseButton).button_index
		btn.pressed = (event as InputEventMouseButton).pressed
		btn.position = vp_pos
		btn.global_position = vp_pos
		new_event = btn
	elif event is InputEventMouseMotion:
		var mot = InputEventMouseMotion.new()
		mot.position = vp_pos
		mot.global_position = vp_pos
		mot.relative = (event as InputEventMouseMotion).relative
		new_event = mot
	else:
		return
	paper_viewport.push_input(new_event)

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var key = event as InputEventKey
	if not key.pressed:
		return
	
	if key.keycode == KEY_ESCAPE:
		if rulebook_popup and rulebook_popup.visible:
			_close_rulebook()
		elif not busy:
			_back()
		return
	
	if key.keycode == KEY_SPACE or key.keycode == KEY_ENTER:
		if rulebook_popup and rulebook_popup.visible:
			_close_rulebook()
		return
	
	if event_active and event_overlay and event_overlay.visible:
		if key.keycode == KEY_A or key.keycode == KEY_1:
			_on_event_choice_a()
		elif key.keycode == KEY_B or key.keycode == KEY_2:
			_on_event_choice_b()
		return
	
	# Pressing 3 or R toggles rulebook
	if key.keycode == KEY_3 or key.keycode == KEY_R:
		if rulebook_popup and rulebook_popup.visible:
			_close_rulebook()
			return
	
	if rulebook_popup and rulebook_popup.visible:
		# Any other key closes rulebook
		_close_rulebook()
		return
	if busy or not _is_cursor_mode():
		return
	
	match key.keycode:
		KEY_1: _on_open_folder()
		KEY_2: _on_inspect()
		KEY_3: _on_check_rules()
		KEY_4: _on_file_ticket()
		KEY_R: _open_rulebook()
		KEY_A:
			if ticket_filed and "APPROVED" in current_allowed_stamps:
				_stamp("APPROVED")
		KEY_D:
			if ticket_filed and "DENIED" in current_allowed_stamps:
				_stamp("DENIED")
		KEY_H:
			if ticket_filed and "HOLD" in current_allowed_stamps:
				_stamp("HOLD")
		KEY_F:
			if ticket_filed and "FORWARD" in current_allowed_stamps:
				_stamp("FORWARD")
		KEY_N:
			# Secret stamp
			if ticket_filed and _is_secret_target() and _has_secret_stamp():
				_stamp("NOT_A_THING")

func _get_save() -> Node:
	return get_node_or_null("/root/Save")

func _has_secret_stamp() -> bool:
	var save = _get_save()
	if save and "secret_stamp_unlocked" in save:
		return save.secret_stamp_unlocked
	return false

func _is_secret_target() -> bool:
	for target in SECRET_TARGETS:
		if current_ticket_text.contains(target) or target in current_ticket_text:
			return true
	return false

func _apply_settings() -> void:
	var save = _get_save()
	if not save:
		return
	if "vfx_intensity" in save:
		vfx_intensity = clampf(float(save.vfx_intensity), 0.0, 1.0)
	if "reduce_motion" in save:
		reduce_motion = bool(save.reduce_motion)
	if "events_enabled" in save:
		events_enabled = bool(save.events_enabled)

func _populate_rulebook() -> void:
	if not rules_text:
		return
	var dataloader = get_node_or_null("/root/DataLoader")
	if not dataloader or not dataloader.has_method("rules_for_shift"):
		rules_text.text = "No rules loaded."
		return
	var rules = dataloader.rules_for_shift(shift_number)
	if rules.size() == 0:
		rules_text.text = "No rules loaded."
		return
	var text = ""
	for rule in rules:
		text += "%s — %s\n\n" % [rule.get("id", "???"), rule.get("text", "")]
	rules_text.text = text.strip_edges()

func _open_rulebook() -> void:
	if event_active:
		return
	if rulebook_popup:
		rulebook_popup.visible = true
	_play_click()
	if not rules_checked:
		rules_checked = true
		_update_workflow_ui()

func _close_rulebook() -> void:
	if rulebook_popup:
		rulebook_popup.visible = false
	_play_click()

func _on_event_started() -> void:
	if not shift_events or busy or not events_enabled:
		return
	if not shift_events.has_method("get_current_event"):
		return
	var event = shift_events.get_current_event()
	if event.is_empty():
		return
	event_active = true
	_play_glitch()
	if event_title:
		event_title.text = event.get("title", "EVENT")
	if event_body:
		event_body.text = event.get("body", "Something happened.")
	if choice_a_btn:
		choice_a_btn.text = "A) " + event.get("choice_a", "Option A")
	if choice_b_btn:
		choice_b_btn.text = "B) " + event.get("choice_b", "Option B")
	if event_overlay:
		event_overlay.visible = true
	if toast:
		toast.text = "⚠️ EVENT! Press A or B"
	_set_workflow_enabled(false)

func _on_event_choice_a() -> void:
	if not shift_events or not shift_events.has_method("choose"):
		return
	_play_click()
	_apply_event_result(shift_events.choose("A"))

func _on_event_choice_b() -> void:
	if not shift_events or not shift_events.has_method("choose"):
		return
	_play_click()
	_apply_event_result(shift_events.choose("B"))

func _apply_event_result(result: Dictionary) -> void:
	mood += result.get("mood", 0)
	contradiction += result.get("contradiction", 0)
	_update_meters()
	var r_toast = result.get("toast", "")
	if r_toast != "" and toast:
		toast.text = "📢 " + r_toast
	if result.get("contradiction", 0) >= 2:
		_play_tremor()

func _on_event_ended(_m: int, _c: int) -> void:
	event_active = false
	if event_overlay:
		event_overlay.visible = false
	_set_workflow_enabled(true)

func _set_workflow_enabled(enabled: bool) -> void:
	if open_folder_btn:
		open_folder_btn.disabled = not enabled or folder_opened
	if inspect_btn:
		inspect_btn.disabled = not enabled or attachment_inspected or not folder_opened
	if check_rules_btn:
		check_rules_btn.disabled = not enabled or rules_checked or not folder_opened
	if file_ticket_btn:
		file_ticket_btn.disabled = not enabled or ticket_filed
	if rulebook_button:
		rulebook_button.disabled = not enabled

func _compute_requirements(t: Dictionary) -> void:
	folder_opened = false
	attachment_inspected = false
	rules_checked = false
	ticket_filed = false
	var att = t.get("attachment", "")
	requires_inspect = att != "" and att != "N/A" and att != "None"
	var ticket_type = t.get("type", "standard")
	requires_rules = ticket_type in ["classified", "secret"]
	if not requires_rules:
		var outcomes = t.get("outcomes", {})
		for stamp_name in outcomes:
			if int(outcomes[stamp_name].get("contradiction_delta", 0)) >= 2:
				requires_rules = true
				break

func _show(i: int) -> void:
	if i >= tickets.size():
		_complete()
		return
	
	# Mid-shift story message
	if i == 4 or i == 6:
		if story_director and story_director.has_method("on_mid_shift"):
			story_director.on_mid_shift()
	
	index = i
	var t = tickets[i]
	_compute_requirements(t)
	current_allowed_stamps = t.get("allowed_stamps", [])
	current_ticket_text = t.get("text", "")
	
	if ticket_text:
		ticket_text.text = current_ticket_text
	if attachment:
		var att = t.get("attachment", "N/A")
		attachment.text = "📎 " + att if att != "" else "📎 N/A"
	if progress:
		progress.text = "Ticket %d / %d" % [i + 1, tickets.size()]
	
	_update_meters()
	_update_workflow_ui()
	if stamp_buttons:
		for c in stamp_buttons.get_children():
			c.queue_free()

func _update_workflow_ui() -> void:
	if event_active:
		return
	if open_folder_btn:
		open_folder_btn.text = "[1] ✓ Opened" if folder_opened else "[1] 📁 Open"
		open_folder_btn.disabled = folder_opened
	if inspect_btn:
		if requires_inspect:
			inspect_btn.visible = true
			inspect_btn.text = "[2] ✓ Done" if attachment_inspected else "[2] 🔍 Inspect"
			inspect_btn.disabled = attachment_inspected or not folder_opened
		else:
			inspect_btn.visible = false
			attachment_inspected = true
	if check_rules_btn:
		if requires_rules:
			check_rules_btn.visible = true
			check_rules_btn.text = "[3] ✓ OK" if rules_checked else "[3] 📋 Rules"
			check_rules_btn.disabled = rules_checked or not folder_opened
		else:
			check_rules_btn.visible = false
	var can_file = folder_opened
	if requires_inspect:
		can_file = can_file and attachment_inspected
	if requires_rules:
		can_file = can_file and rules_checked
	if file_ticket_btn:
		file_ticket_btn.text = "[4] ✓ Filed" if ticket_filed else "[4] 📤 File"
		file_ticket_btn.disabled = ticket_filed or not can_file
	if ticket_filed:
		_create_stamp_buttons()

func _create_stamp_buttons() -> void:
	if not stamp_buttons:
		return
	for c in stamp_buttons.get_children():
		c.queue_free()
	var t = tickets[index]
	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 10)
	stamp_buttons.add_child(hbox)
	
	for stamp in t.get("allowed_stamps", []):
		var btn = Button.new()
		var key_hint = ""
		match stamp:
			"APPROVED": key_hint = "[A] "
			"DENIED": key_hint = "[D] "
			"HOLD": key_hint = "[H] "
			"FORWARD": key_hint = "[F] "
		var emoji = "🔴 " if stamp == "DENIED" else "🟢 " if stamp == "APPROVED" else "🟡 "
		btn.text = key_hint + emoji + stamp
		btn.custom_minimum_size = Vector2(120, 35)
		btn.pressed.connect(_stamp.bind(stamp))
		hbox.add_child(btn)
	
	# Add secret stamp if available
	if _is_secret_target() and _has_secret_stamp():
		var secret_btn = Button.new()
		secret_btn.text = "[N] ⬛ NOT_A_THING"
		secret_btn.custom_minimum_size = Vector2(150, 35)
		secret_btn.modulate = Color(0.5, 0.5, 0.6)
		secret_btn.pressed.connect(_stamp.bind("NOT_A_THING"))
		hbox.add_child(secret_btn)
	
	if toast:
		toast.text = "🖋️ Choose stamp!"

func _on_open_folder() -> void:
	if event_active:
		return
	if not folder_opened:
		folder_opened = true
		toast.text = "📂 Folder opened" if toast else ""
		_play_click()
		_update_workflow_ui()

func _on_inspect() -> void:
	if event_active:
		return
	if folder_opened and not attachment_inspected:
		attachment_inspected = true
		toast.text = "🔍 Attachment checked" if toast else ""
		_play_click()
		_update_workflow_ui()

func _on_check_rules() -> void:
	if event_active:
		return
	_open_rulebook()

func _on_file_ticket() -> void:
	if event_active:
		return
	var can_file = folder_opened
	if requires_inspect:
		can_file = can_file and attachment_inspected
	if requires_rules:
		can_file = can_file and rules_checked
	if can_file and not ticket_filed:
		ticket_filed = true
		toast.text = "📤 Filed! Choose stamp" if toast else ""
		_play_click()
		_update_workflow_ui()

func _stamp(name: String) -> void:
	if busy or event_active:
		return
	if not ticket_filed:
		contradiction += 1
		_update_meters()
		toast.text = "⚠️ Complete workflow first!" if toast else ""
		_play_error()
		_play_tremor()
		return
	
	# Handle secret stamp
	if name == "NOT_A_THING":
		if not _is_secret_target() or not _has_secret_stamp():
			toast.text = "⚠️ Invalid stamp" if toast else ""
			_play_error()
			return
		var save = _get_save()
		if save and save.has_method("track_secret_stamp_use"):
			save.track_secret_stamp_use(current_ticket_text)
		toast.text = "⬛ NOT_A_THING applied..." if toast else ""
		_play_glitch()
		_play_tremor()
		busy = true
		await _animate_ticket_out()
		busy = false
		_show(index + 1)
		return
	
	if name not in current_allowed_stamps:
		toast.text = "⚠️ Stamp unavailable" if toast else ""
		_play_error()
		return
	
	# Track Level 7 denies
	var t = tickets[index]
	var ticket_type = t.get("type", "standard")
	if name == "DENIED" and ticket_type == "level7":
		var save = _get_save()
		if save and save.has_method("track_level7_deny"):
			save.track_level7_deny()
	
	busy = true
	var outcomes = t.get("outcomes", {})
	if outcomes.has(name):
		var o = outcomes[name]
		var toast_id = o.get("toast_id", "")
		var dataloader = get_node_or_null("/root/DataLoader")
		if dataloader and dataloader.has_method("toast_text") and toast:
			toast.text = "💬 " + dataloader.toast_text(toast_id)
		mood += int(o.get("mood_delta", 0))
		var delta = int(o.get("contradiction_delta", 0))
		contradiction += delta
		_update_meters()
		_update_horror_tension()
		_play_stamp(name == "APPROVED")
		if delta >= 3:
			_play_glitch()
			_play_tremor()
			_trigger_horror_on_bad_decision()
		if stamp_buttons:
			for c in stamp_buttons.get_children():
				for b in c.get_children():
					if b is Button:
						b.disabled = true
		await _animate_ticket_out()
		busy = false
		_show(index + 1)
	else:
		toast.text = "⚠️ Invalid stamp" if toast else ""
		_play_error()
		busy = false

func _animate_ticket_out() -> void:
	if not ticket_vbox:
		return
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(ticket_vbox, "position:x", -400, 0.2)
	await tween.finished
	ticket_vbox.position.x = 400
	var tween_in = create_tween()
	tween_in.set_trans(Tween.TRANS_QUAD)
	tween_in.set_ease(Tween.EASE_OUT)
	tween_in.tween_property(ticket_vbox, "position:x", 0, 0.2)
	await tween_in.finished

func _play_tremor() -> void:
	var shake_scale = 1.0 if not reduce_motion else 0.3
	var effect_scale = vfx_intensity
	if paper_background:
		var tween = create_tween()
		var flash = Color(1, 0.8, 0.7).lerp(original_paper_color, 1.0 - effect_scale)
		tween.tween_property(paper_background, "color", flash, 0.1)
		tween.tween_property(paper_background, "color", original_paper_color, 0.15)
	if scanline_overlay and scanline_overlay.material:
		var mat = scanline_overlay.material as ShaderMaterial
		if mat:
			var max_glitch = 0.5 * effect_scale
			var tween2 = create_tween()
			tween2.tween_method(_set_glitch, 0.0, max_glitch, 0.1)
			tween2.tween_method(_set_glitch, max_glitch, 0.0, 0.2)
	if is_instance_valid(office_3d) and office_3d.has_method("apply_tremor"):
		office_3d.apply_tremor(0.6 * shake_scale, 0.3)

func _set_glitch(v: float) -> void:
	if scanline_overlay and scanline_overlay.material:
		var mat = scanline_overlay.material as ShaderMaterial
		if mat:
			mat.set_shader_parameter("glitch_intensity", v)

func _play_click() -> void:
	if sfx and sfx.has_method("play_click"):
		sfx.play_click()

func _play_stamp(approved: bool) -> void:
	if sfx and sfx.has_method("play_stamp"):
		sfx.play_stamp(approved)

func _play_error() -> void:
	if sfx and sfx.has_method("play_error"):
		sfx.play_error()

func _play_glitch() -> void:
	if sfx and sfx.has_method("play_glitch"):
		sfx.play_glitch()

func _update_meters() -> void:
	if mood_value:
		mood_value.text = "Mood: %+d" % mood
	if contradiction_value:
		contradiction_value.text = "Contra: %d" % contradiction

func _complete() -> void:
	if shift_events and shift_events.has_method("stop"):
		shift_events.stop()
	
	# Story end message
	if story_director and story_director.has_method("on_shift_end"):
		story_director.on_shift_end()
	
	var save = _get_save()
	if save:
		if save.has_method("update_totals"):
			save.update_totals(mood, contradiction)
		if shift_number < 10:
			if save.has_method("unlock_shift"):
				save.unlock_shift(shift_number + 1)
			if save.has_method("write_save"):
				save.write_save()
	
	if open_folder_btn:
		open_folder_btn.visible = false
	if inspect_btn:
		inspect_btn.visible = false
	if check_rules_btn:
		check_rules_btn.visible = false
	if file_ticket_btn:
		file_ticket_btn.visible = false
	
	if ticket_text:
		ticket_text.text = "SHIFT %02d COMPLETE" % shift_number
	if attachment:
		attachment.text = "Thank you for your service."
	if progress:
		progress.text = "Mood: %+d | Contra: %d" % [mood, contradiction]
	
	if stamp_buttons:
		for c in stamp_buttons.get_children():
			c.queue_free()
	
	# Check for endings (Shift 10 only)
	if shift_number >= 10:
		_determine_ending()
	else:
		toast.text = "🎉 Complete! Esc to exit" if toast else ""
		if stamp_buttons:
			var next_btn = Button.new()
			next_btn.text = "▶ Next Shift"
			next_btn.custom_minimum_size = Vector2(120, 35)
			next_btn.pressed.connect(_next_shift)
			stamp_buttons.add_child(next_btn)

func _determine_ending() -> void:
	var save = _get_save()
	var ending_type = "compliance"
	
	# Check for Transcendence (secret ending)
	if save and save.has_method("has_all_secret_targets") and save.has_all_secret_targets():
		ending_type = "transcendence"
	# Check for Dissolution
	elif save and "denied_level7_count" in save and save.denied_level7_count >= 3:
		ending_type = "dissolution"
	elif save and "total_contradiction" in save and save.total_contradiction >= 75:
		ending_type = "dissolution"
	# Default: Compliance
	else:
		ending_type = "compliance"
	
	# Set ending in gamestate and go to ending scene
	var gamestate = get_node_or_null("/root/GameState")
	if gamestate:
		gamestate.set("ending_type", ending_type)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/Ending.tscn")

func _next_shift() -> void:
	var gamestate = get_node_or_null("/root/GameState")
	if gamestate and "selected_shift" in gamestate:
		gamestate.selected_shift = shift_number + 1
	get_tree().reload_current_scene()

func _back() -> void:
	if shift_events and shift_events.has_method("stop"):
		shift_events.stop()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_play_click()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

# === HORROR EVENTS SYSTEM ===

func _setup_horror_events() -> void:
	# Load horror script
	var horror_script = load("res://scripts/HorrorEvents.gd")
	if horror_script:
		horror_events = Node.new()
		horror_events.set_script(horror_script)
		horror_events.name = "HorrorEvents"
		add_child(horror_events)
		
		# Set references
		if horror_events.has_method("set_shift"):
			horror_events.set_shift(shift_number)
		
		# Pass camera and light references
		if camera_3d:
			horror_events.camera = camera_3d
		
		# Collect office lights and find clerk
		if office_3d:
			var clerk = office_3d.get_node_or_null("Clerk")
			if clerk:
				horror_events.clerk = clerk
				# Enable creepy mode for later shifts
				if shift_number >= 5 and clerk.has_method("set_creepy_mode"):
					clerk.set_creepy_mode(true)
			
			for child in office_3d.get_children():
				if child is Light3D:
					horror_events.office_lights.append(child)
				for subchild in child.get_children():
					if subchild is Light3D:
						horror_events.office_lights.append(subchild)
		
		# Connect signal
		if horror_events.has_signal("horror_event_triggered"):
			horror_events.connect("horror_event_triggered", _on_horror_event)
		
		print("[Shift] Horror system initialized - Shift %d" % shift_number)

func _on_horror_event(event_type: String) -> void:
	# Show subtle toast for some events
	if toast:
		match event_type:
			"WHISPER":
				toast.text = "...did you hear that?"
			"SHADOW_PASS":
				toast.text = "...something moved..."
			"INTERCOM_VOICE":
				toast.text = "*static* ...remain calm... *static*"

func _update_horror_tension() -> void:
	if horror_events:
		# Calculate tension from contradiction meter
		var tension = clampf(float(contradiction) / 100.0, 0.0, 1.0)
		if horror_events.has_method("set_tension"):
			horror_events.set_tension(tension)

func _trigger_horror_on_bad_decision() -> void:
	if horror_events and horror_events.has_method("on_wrong_decision"):
		horror_events.on_wrong_decision()

func _on_story_horror(intensity: String) -> void:
	if horror_events and horror_events.has_method("trigger_story_scare"):
		horror_events.trigger_story_scare(intensity)

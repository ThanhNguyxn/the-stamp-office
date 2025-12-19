extends Control
## Shift - Desk job workflow gameplay with world-space UI on 3D paper
## UI rendered to PaperViewport and displayed on 3D PaperScreen mesh
## Input is raycasted from 3D camera to paper and forwarded to viewport

# Paper viewport (contains the UI)
@onready var paper_viewport: SubViewport = $PaperViewport

# UI elements inside PaperViewport
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

# Popups inside PaperViewport
@onready var rulebook_popup: PanelContainer = $PaperViewport/PaperUI/RulebookPopup
@onready var rules_text: Label = $PaperViewport/PaperUI/RulebookPopup/VBox/Scroll/RulesText
@onready var rulebook_close_button: Button = $PaperViewport/PaperUI/RulebookPopup/VBox/RulebookCloseButton
@onready var event_overlay: PanelContainer = $PaperViewport/PaperUI/EventOverlay
@onready var event_title: Label = $PaperViewport/PaperUI/EventOverlay/VBox/EventTitle
@onready var event_body: Label = $PaperViewport/PaperUI/EventOverlay/VBox/EventBody
@onready var choice_a_btn: Button = $PaperViewport/PaperUI/EventOverlay/VBox/ButtonBox/ChoiceA
@onready var choice_b_btn: Button = $PaperViewport/PaperUI/EventOverlay/VBox/ButtonBox/ChoiceB

# Bottom HUD (2D overlay)
@onready var toast: Label = $BottomHUD/VBox/Toast
@onready var progress: Label = $BottomHUD/VBox/Progress

# Visual effects
@onready var scanline_overlay: ColorRect = $ScanlineOverlay

# Audio (null-safe)
@onready var sfx: Node = $Sfx

# Events system (null-safe)
@onready var shift_events: Node = $ShiftEvents

# 3D office reference
@onready var office_viewport: SubViewport = $OfficeViewportContainer/OfficeViewport
var office_3d: Node3D = null
var paper_screen: MeshInstance3D = null
var paper_area: Area3D = null
var camera_3d: Camera3D = null

# Game state
var shift_number: int = 1
var tickets: Array = []
var index: int = 0
var mood: int = 0
var contradiction: int = 0
var busy: bool = false
var event_active: bool = false
var original_paper_color: Color = Color(0.95, 0.93, 0.88)

# Settings-driven modifiers
var vfx_intensity: float = 1.0
var reduce_motion: bool = false
var events_enabled: bool = true

# Workflow state per ticket
var folder_opened: bool = false
var attachment_inspected: bool = false
var rules_checked: bool = false
var ticket_filed: bool = false

# Requirements for current ticket
var requires_inspect: bool = false
var requires_rules: bool = false

func _ready() -> void:
	# Get 3D references (null-safe)
	if office_viewport and office_viewport.get_child_count() > 0:
		office_3d = office_viewport.get_child(0)
		if office_3d:
			camera_3d = office_3d.get_node_or_null("Camera3D")
			var desk = office_3d.get_node_or_null("Desk")
			if desk:
				paper_screen = desk.get_node_or_null("PaperScreen")
				if paper_screen:
					paper_area = paper_screen.get_node_or_null("PaperArea")
	
	# Apply paper viewport texture to 3D paper screen
	_setup_paper_texture()
	
	# Apply saved settings (null-safe)
	_apply_settings()
	
	# Wire buttons (null-safe)
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
	
	# Wire event system (null-safe)
	if shift_events:
		if shift_events.has_signal("event_started"):
			shift_events.connect("event_started", _on_event_started)
		if shift_events.has_signal("event_ended"):
			shift_events.connect("event_ended", _on_event_ended)
	
	if toast:
		toast.text = ""
	if event_overlay:
		event_overlay.visible = false
	
	# Get selected shift from GameState (null-safe)
	var gamestate = get_node_or_null("/root/GameState")
	if gamestate and "selected_shift" in gamestate:
		shift_number = int(gamestate.selected_shift)
	
	if header:
		header.text = "SHIFT %02d" % shift_number
	
	# Load tickets (null-safe)
	var dataloader = get_node_or_null("/root/DataLoader")
	if dataloader and dataloader.has_method("load_shift"):
		tickets = dataloader.load_shift(shift_number)
	
	# Populate rulebook
	_populate_rulebook()
	
	# Show rulebook on start
	_open_rulebook()
	
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

## Setup paper viewport texture onto 3D paper mesh
func _setup_paper_texture() -> void:
	if not paper_viewport or not paper_screen:
		return
	
	# Create material with viewport texture
	var mat = StandardMaterial3D.new()
	mat.albedo_texture = paper_viewport.get_texture()
	mat.emission_enabled = true
	mat.emission = Color(1, 1, 1, 1)
	mat.emission_energy_multiplier = 0.3
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	paper_screen.material_override = mat

## Handle input - raycast to paper and forward to viewport
func _input(event: InputEvent) -> void:
	if not camera_3d or not paper_area or not paper_viewport:
		return
	
	if event is InputEventMouse:
		var mouse_event = event as InputEventMouse
		var mouse_pos = mouse_event.position
		
		# Convert screen position to ray
		var from = camera_3d.project_ray_origin(mouse_pos)
		var dir = camera_3d.project_ray_normal(mouse_pos)
		var to = from + dir * 100.0
		
		# Raycast in physics space
		var space_state = office_viewport.world_3d.direct_space_state
		if not space_state:
			return
		
		var query = PhysicsRayQueryParameters3D.create(from, to)
		query.collide_with_areas = true
		query.collide_with_bodies = false
		var result = space_state.intersect_ray(query)
		
		if result.is_empty():
			return
		
		# Check if we hit the paper area
		var collider = result.get("collider")
		if collider != paper_area:
			return
		
		# Get hit position and convert to paper local coords
		var hit_pos = result.get("position", Vector3.ZERO)
		var local_pos = paper_screen.global_transform.affine_inverse() * hit_pos
		
		# Paper quad is 1.6 x 1.0 centered at origin, rotated to lie flat
		# local_pos.x is along width, local_pos.y is along height (since quad is rotated)
		var paper_size = Vector2(1.6, 1.0)
		var uv = Vector2(
			(local_pos.x / paper_size.x) + 0.5,
			(-local_pos.y / paper_size.y) + 0.5
		)
		
		# Clamp UV to valid range
		uv = uv.clamp(Vector2.ZERO, Vector2.ONE)
		
		# Convert to viewport coords
		var vp_size = paper_viewport.size
		var vp_pos = Vector2(uv.x * vp_size.x, uv.y * vp_size.y)
		
		# Create new event with remapped position
		var new_event: InputEventMouse
		if event is InputEventMouseButton:
			var btn_event = InputEventMouseButton.new()
			btn_event.button_index = (event as InputEventMouseButton).button_index
			btn_event.pressed = (event as InputEventMouseButton).pressed
			btn_event.position = vp_pos
			btn_event.global_position = vp_pos
			new_event = btn_event
		elif event is InputEventMouseMotion:
			var motion_event = InputEventMouseMotion.new()
			motion_event.position = vp_pos
			motion_event.global_position = vp_pos
			motion_event.relative = (event as InputEventMouseMotion).relative
			new_event = motion_event
		else:
			return
		
		# Forward to viewport
		paper_viewport.push_input(new_event)

## Get Save autoload node (null-safe)
func _get_save() -> Node:
	var save_node = get_node_or_null("/root/Save")
	if save_node:
		return save_node
	if Engine.has_singleton("Save"):
		return Engine.get_singleton("Save")
	return null

func _has_save() -> bool:
	return _get_save() != null

## Apply settings from Save (null-safe)
func _apply_settings() -> void:
	var save_node = _get_save()
	if not save_node:
		return
	
	if "vfx_intensity" in save_node:
		vfx_intensity = clampf(float(save_node.vfx_intensity), 0.0, 1.0)
	if "reduce_motion" in save_node:
		reduce_motion = bool(save_node.reduce_motion)
	if "events_enabled" in save_node:
		events_enabled = bool(save_node.events_enabled)
	
	if save_node.has_method("apply_settings_to_scene"):
		save_node.apply_settings_to_scene(self)
	
	if not events_enabled and shift_events and shift_events.has_method("stop"):
		shift_events.stop()

## Populate rulebook popup
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
		var id = rule.get("id", "???")
		var rule_text = rule.get("text", "")
		text += "%s — %s\n\n" % [id, rule_text]
	
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

## Event handlers
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
	_set_workflow_enabled(false)

func _on_event_choice_a() -> void:
	if not shift_events or not shift_events.has_method("choose"):
		return
	_play_click()
	var result = shift_events.choose("A")
	_apply_event_result(result)

func _on_event_choice_b() -> void:
	if not shift_events or not shift_events.has_method("choose"):
		return
	_play_click()
	var result = shift_events.choose("B")
	_apply_event_result(result)

func _apply_event_result(result: Dictionary) -> void:
	mood += result.get("mood", 0)
	contradiction += result.get("contradiction", 0)
	_update_meters()
	
	var result_toast = result.get("toast", "")
	if result_toast != "" and toast:
		toast.text = "📢 " + result_toast
	
	if result.get("contradiction", 0) >= 2:
		_play_tremor()

func _on_event_ended(_mood_delta: int, _contradiction_delta: int) -> void:
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

## Workflow
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
	
	index = i
	var t = tickets[i]
	_compute_requirements(t)
	
	if ticket_text:
		ticket_text.text = t.get("text", "")
	if attachment:
		var att = t.get("attachment", "N/A")
		attachment.text = "📎 " + att if att != "" else "📎 N/A"
	if progress:
		progress.text = "Ticket %d / %d" % [i + 1, tickets.size()]
	if toast:
		toast.text = "📁 Follow the workflow steps"
	_update_meters()
	_update_workflow_ui()
	
	if stamp_buttons:
		for c in stamp_buttons.get_children():
			c.queue_free()

func _update_workflow_ui() -> void:
	if event_active:
		return
	
	if open_folder_btn:
		open_folder_btn.text = "✓ Opened" if folder_opened else "📁 Open"
		open_folder_btn.disabled = folder_opened
	
	if inspect_btn:
		if requires_inspect:
			inspect_btn.visible = true
			inspect_btn.text = "✓ Done" if attachment_inspected else "🔍 Inspect"
			inspect_btn.disabled = attachment_inspected or not folder_opened
		else:
			inspect_btn.visible = false
			attachment_inspected = true
	
	if check_rules_btn:
		if requires_rules:
			check_rules_btn.visible = true
			check_rules_btn.text = "✓ OK" if rules_checked else "📋 Rules"
			check_rules_btn.disabled = rules_checked or not folder_opened
		else:
			check_rules_btn.visible = false
	
	var can_file = folder_opened
	if requires_inspect:
		can_file = can_file and attachment_inspected
	if requires_rules:
		can_file = can_file and rules_checked
	
	if file_ticket_btn:
		file_ticket_btn.text = "✓ Filed" if ticket_filed else "📤 File"
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
		btn.text = "🔴 " + stamp if stamp == "DENIED" else "🟢 " + stamp if stamp == "APPROVED" else "🟡 " + stamp
		btn.custom_minimum_size = Vector2(100, 35)
		btn.pressed.connect(_stamp.bind(stamp))
		hbox.add_child(btn)
	
	if toast:
		toast.text = "🖋️ Ready to stamp!"

func _on_open_folder() -> void:
	if event_active:
		return
	if not folder_opened:
		folder_opened = true
		if toast:
			toast.text = "📂 Folder opened"
		_play_click()
		_update_workflow_ui()

func _on_inspect() -> void:
	if event_active:
		return
	if folder_opened and not attachment_inspected:
		attachment_inspected = true
		if toast:
			toast.text = "🔍 Attachment verified"
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
		if toast:
			toast.text = "📤 Ticket filed. Select stamp."
		_play_click()
		_update_workflow_ui()

func _stamp(name: String) -> void:
	if busy or event_active:
		return
	
	if not ticket_filed:
		contradiction += 1
		_update_meters()
		if toast:
			toast.text = "⚠️ Process violation! Complete workflow first."
		_play_error()
		_play_tremor()
		return
	
	busy = true
	var t = tickets[index]
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
		
		_play_stamp(name == "APPROVED")
		
		if delta >= 3:
			_play_glitch()
			_play_tremor()
		
		if stamp_buttons:
			for c in stamp_buttons.get_children():
				for b in c.get_children():
					if b is Button:
						b.disabled = true
		
		await _animate_ticket_out()
		busy = false
		_show(index + 1)
	else:
		if toast:
			toast.text = "⚠️ Invalid stamp"
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

## Visual effects
func _play_tremor() -> void:
	var shake_scale = 1.0 if not reduce_motion else 0.3
	var effect_scale = vfx_intensity
	
	# Flash paper background
	if paper_background:
		var tween = create_tween()
		var flash_color = Color(1, 0.8, 0.7).lerp(original_paper_color, 1.0 - effect_scale)
		tween.tween_property(paper_background, "color", flash_color, 0.1)
		tween.tween_property(paper_background, "color", original_paper_color, 0.15)
	
	# Scanline glitch
	if scanline_overlay and scanline_overlay.material:
		var mat = scanline_overlay.material as ShaderMaterial
		if mat:
			var max_glitch = 0.5 * effect_scale
			var overlay_tween = create_tween()
			overlay_tween.tween_method(_set_glitch_intensity, 0.0, max_glitch, 0.1)
			overlay_tween.tween_method(_set_glitch_intensity, max_glitch, 0.0, 0.2)
	
	# 3D tremor
	if office_3d and office_3d.has_method("apply_tremor"):
		office_3d.apply_tremor(0.6 * shake_scale, 0.3)

func _set_glitch_intensity(value: float) -> void:
	if scanline_overlay and scanline_overlay.material:
		var mat = scanline_overlay.material as ShaderMaterial
		if mat:
			mat.set_shader_parameter("glitch_intensity", value)

## Sound effects (null-safe)
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

## Shift complete
func _complete() -> void:
	if shift_events and shift_events.has_method("stop"):
		shift_events.stop()
	
	var save_node = _get_save()
	if save_node and shift_number < 10:
		if save_node.has_method("unlock_shift"):
			save_node.unlock_shift(shift_number + 1)
		if save_node.has_method("write_save"):
			save_node.write_save()
	
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
	if toast:
		toast.text = "🎉 All tickets processed!"
	if progress:
		progress.text = "Mood: %+d | Contra: %d" % [mood, contradiction]
	
	if stamp_buttons:
		for c in stamp_buttons.get_children():
			c.queue_free()
		
		if shift_number < 10:
			var next_btn = Button.new()
			next_btn.text = "▶ Next"
			next_btn.custom_minimum_size = Vector2(100, 35)
			next_btn.pressed.connect(_next_shift)
			stamp_buttons.add_child(next_btn)

func _next_shift() -> void:
	var gamestate = get_node_or_null("/root/GameState")
	if gamestate and "selected_shift" in gamestate:
		gamestate.selected_shift = shift_number + 1
	get_tree().reload_current_scene()

func _back() -> void:
	if shift_events and shift_events.has_method("stop"):
		shift_events.stop()
	_play_click()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

extends Control
## Shift - Desk job workflow gameplay with 4-step ticket processing
## Includes procedural SFX, visual effects, random interrupt events, and save integration
## Defensive: null-checks everywhere for Save autoload and nodes

# UI references
@onready var background: ColorRect = $Background
@onready var vbox: VBoxContainer = $VBox
@onready var header: Label = $VBox/HeaderRow/Header
@onready var rulebook_button: Button = $VBox/HeaderRow/RulebookButton
@onready var ticket_panel: PanelContainer = $VBox/TicketPanel
@onready var ticket_vbox: VBoxContainer = $VBox/TicketPanel/TicketVBox
@onready var ticket_text: Label = $VBox/TicketPanel/TicketVBox/TicketText
@onready var attachment: Label = $VBox/TicketPanel/TicketVBox/Attachment
@onready var stamp_buttons: VBoxContainer = $VBox/StampButtons
@onready var toast: Label = $VBox/ToastPanel/Toast
@onready var mood_value: Label = $VBox/MetersBox/MoodValue
@onready var contradiction_value: Label = $VBox/MetersBox/ContradictionValue
@onready var progress: Label = $VBox/Progress
@onready var back_button: Button = $VBox/BackButton

# Workflow bar buttons
@onready var open_folder_btn: Button = $VBox/WorkflowBar/OpenFolderBtn
@onready var inspect_btn: Button = $VBox/WorkflowBar/InspectBtn
@onready var check_rules_btn: Button = $VBox/WorkflowBar/CheckRulesBtn
@onready var file_ticket_btn: Button = $VBox/WorkflowBar/FileTicketBtn

# Rulebook popup references
@onready var rulebook_popup: PanelContainer = $RulebookPopup
@onready var rules_text: Label = $RulebookPopup/VBox/Scroll/RulesText
@onready var rulebook_close_button: Button = $RulebookPopup/VBox/RulebookCloseButton

# Event overlay references
@onready var event_overlay: PanelContainer = $EventOverlay
@onready var event_title: Label = $EventOverlay/VBox/EventTitle
@onready var event_body: Label = $EventOverlay/VBox/EventBody
@onready var choice_a_btn: Button = $EventOverlay/VBox/ButtonBox/ChoiceA
@onready var choice_b_btn: Button = $EventOverlay/VBox/ButtonBox/ChoiceB

# Visual effects
@onready var scanline_overlay: ColorRect = $ScanlineOverlay

# Audio (null-safe)
@onready var sfx: Node = $Sfx

# Events system (null-safe)
@onready var shift_events: Node = $ShiftEvents

# 3D office reference
@onready var office_viewport: SubViewport = $OfficeViewportContainer/OfficeViewport
var office_3d: Node3D = null

# Game state
var shift_number: int = 1
var tickets: Array = []
var index: int = 0
var mood: int = 0
var contradiction: int = 0
var busy: bool = false
var event_active: bool = false
var original_bg_color: Color
var original_vbox_pos: Vector2

# Settings-driven modifiers (defaults if Save not available)
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
	# Store original values for effects
	if background:
		original_bg_color = background.color
	if vbox:
		original_vbox_pos = vbox.position
	
	# Get reference to Office3D scene (null-safe)
	if office_viewport and office_viewport.get_child_count() > 0:
		office_3d = office_viewport.get_child(0)
	
	# Apply saved settings (null-safe)
	_apply_settings()
	
	# Wire main buttons (null-safe)
	if back_button:
		back_button.pressed.connect(_back)
		back_button.visible = false
	if rulebook_button:
		rulebook_button.pressed.connect(_open_rulebook)
	if rulebook_close_button:
		rulebook_close_button.pressed.connect(_close_rulebook)
	
	# Wire workflow buttons (null-safe)
	if open_folder_btn:
		open_folder_btn.pressed.connect(_on_open_folder)
	if inspect_btn:
		inspect_btn.pressed.connect(_on_inspect)
	if check_rules_btn:
		check_rules_btn.pressed.connect(_on_check_rules)
	if file_ticket_btn:
		file_ticket_btn.pressed.connect(_on_file_ticket)
	
	# Wire event buttons (null-safe)
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
	
	# Populate rulebook with this shift's rules
	_populate_rulebook()
	
	# Show rulebook automatically on shift start
	_open_rulebook()
	
	if tickets.size() > 0:
		_show(0)
		# Start event system after first ticket (if enabled)
		if shift_events and events_enabled and shift_events.has_method("start"):
			shift_events.start()
	else:
		if ticket_text:
			ticket_text.text = "No tickets found"
		if attachment:
			attachment.text = "Run: python tools/sync_game_data.py"
		_update_workflow_ui()

## Get Save autoload node (null-safe, multiple methods)
func _get_save() -> Node:
	# Try direct path first
	var save_node = get_node_or_null("/root/Save")
	if save_node:
		return save_node
	
	# Try Engine singleton (Godot 4 method)
	if Engine.has_singleton("Save"):
		return Engine.get_singleton("Save")
	
	return null

## Check if Save autoload exists
func _has_save() -> bool:
	return _get_save() != null

## Apply settings from Save autoload (null-safe)
func _apply_settings() -> void:
	var save_node = _get_save()
	if not save_node:
		return
	
	# Store settings locally with validation
	if "vfx_intensity" in save_node:
		vfx_intensity = clampf(float(save_node.vfx_intensity), 0.0, 1.0)
	if "reduce_motion" in save_node:
		reduce_motion = bool(save_node.reduce_motion)
	if "events_enabled" in save_node:
		events_enabled = bool(save_node.events_enabled)
	
	# Apply to scene components
	if save_node.has_method("apply_settings_to_scene"):
		save_node.apply_settings_to_scene(self)
	
	# If events disabled, don't start them
	if not events_enabled and shift_events and shift_events.has_method("stop"):
		shift_events.stop()

## Populate rulebook popup with rules for current shift
func _populate_rulebook() -> void:
	if not rules_text:
		return
	
	var dataloader = get_node_or_null("/root/DataLoader")
	if not dataloader or not dataloader.has_method("rules_for_shift"):
		rules_text.text = "No rules loaded.\n\nPlease run:\npython tools/sync_game_data.py"
		return
	
	var rules = dataloader.rules_for_shift(shift_number)
	if rules.size() == 0:
		rules_text.text = "No rules loaded.\n\nPlease run:\npython tools/sync_game_data.py"
		return
	
	var text = ""
	for rule in rules:
		var id = rule.get("id", "???")
		var rule_text = rule.get("text", "")
		var contradicts = rule.get("contradicts", [])
		
		text += "%s — %s\n" % [id, rule_text]
		
		if contradicts.size() > 0:
			text += "  ⚠ Contradicts: %s\n" % ", ".join(contradicts)
		text += "\n"
	
	rules_text.text = text.strip_edges()

## Open rulebook popup (also counts as "Check Rules" step)
func _open_rulebook() -> void:
	if event_active:
		return  # Can't open rulebook during event
	if rulebook_popup:
		rulebook_popup.visible = true
	_play_click()
	# Mark rules as checked for workflow
	if not rules_checked:
		rules_checked = true
		_update_workflow_ui()

## Close rulebook popup
func _close_rulebook() -> void:
	if rulebook_popup:
		rulebook_popup.visible = false
	_play_click()

## Event started - show overlay
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
	
	# Populate event overlay (null-safe)
	if event_title:
		event_title.text = event.get("title", "EVENT")
	if event_body:
		event_body.text = event.get("body", "Something happened.")
	if choice_a_btn:
		choice_a_btn.text = "A) " + event.get("choice_a", "Option A")
	if choice_b_btn:
		choice_b_btn.text = "B) " + event.get("choice_b", "Option B")
	
	# Show overlay
	if event_overlay:
		event_overlay.visible = true
	
	# Disable workflow buttons
	_set_workflow_enabled(false)

## Event choice A
func _on_event_choice_a() -> void:
	if not shift_events or not shift_events.has_method("choose"):
		return
	_play_click()
	var result = shift_events.choose("A")
	_apply_event_result(result)

## Event choice B
func _on_event_choice_b() -> void:
	if not shift_events or not shift_events.has_method("choose"):
		return
	_play_click()
	var result = shift_events.choose("B")
	_apply_event_result(result)

## Apply event result
func _apply_event_result(result: Dictionary) -> void:
	var mood_delta = result.get("mood", 0)
	var contradiction_delta = result.get("contradiction", 0)
	var result_toast = result.get("toast", "")
	
	mood += mood_delta
	contradiction += contradiction_delta
	_update_meters()
	
	if result_toast != "" and toast:
		toast.text = "📢 " + result_toast
	
	# Tremor for high contradiction
	if contradiction_delta >= 2:
		_play_tremor()

## Event ended
func _on_event_ended(_mood_delta: int, _contradiction_delta: int) -> void:
	event_active = false
	if event_overlay:
		event_overlay.visible = false
	_set_workflow_enabled(true)

## Enable/disable workflow buttons
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

## Determine workflow requirements for a ticket
func _compute_requirements(t: Dictionary) -> void:
	# Reset workflow state
	folder_opened = false
	attachment_inspected = false
	rules_checked = false
	ticket_filed = false
	
	# Check if attachment exists and is meaningful
	var att = t.get("attachment", "")
	requires_inspect = att != "" and att != "N/A" and att != "None"
	
	# Check if rules check is required
	var ticket_type = t.get("type", "standard")
	requires_rules = ticket_type in ["classified", "secret"]
	
	# Also require rules if any outcome has high contradiction
	if not requires_rules:
		var outcomes = t.get("outcomes", {})
		for stamp_name in outcomes:
			var o = outcomes[stamp_name]
			if int(o.get("contradiction_delta", 0)) >= 2:
				requires_rules = true
				break

## Show a ticket
func _show(i: int) -> void:
	if i >= tickets.size():
		_complete()
		return
	
	index = i
	var t = tickets[i]
	
	# Compute workflow requirements for this ticket
	_compute_requirements(t)
	
	# Display ticket content (null-safe)
	if ticket_text:
		ticket_text.text = t.get("text", "")
	if attachment:
		var att = t.get("attachment", "N/A")
		attachment.text = "📎 " + att if att != "" else "📎 N/A"
	if progress:
		progress.text = "Ticket %d / %d" % [i + 1, tickets.size()]
	if toast:
		toast.text = "📁 Please follow the workflow steps"
	_update_meters()
	_update_workflow_ui()
	
	# Clear old stamp buttons (will be created when workflow is complete)
	if stamp_buttons:
		for c in stamp_buttons.get_children():
			c.queue_free()

## Update workflow button states and create stamp buttons when ready
func _update_workflow_ui() -> void:
	# Don't update if event is active
	if event_active:
		return
	
	# Update button visual states (completed steps get a checkmark)
	if open_folder_btn:
		open_folder_btn.text = "✓ Folder Opened" if folder_opened else "📁 Open Folder"
		open_folder_btn.disabled = folder_opened
	
	# Inspect requires folder to be opened first
	if inspect_btn:
		if requires_inspect:
			inspect_btn.visible = true
			inspect_btn.text = "✓ Inspected" if attachment_inspected else "🔍 Inspect"
			inspect_btn.disabled = attachment_inspected or not folder_opened
		else:
			inspect_btn.visible = false
			attachment_inspected = true  # Auto-complete if not required
	
	# Check Rules requires folder opened
	if check_rules_btn:
		if requires_rules:
			check_rules_btn.visible = true
			check_rules_btn.text = "✓ Rules OK" if rules_checked else "📋 Check Rules"
			check_rules_btn.disabled = rules_checked or not folder_opened
		else:
			check_rules_btn.visible = false
	
	# File Ticket requires all previous steps
	var can_file = folder_opened
	if requires_inspect:
		can_file = can_file and attachment_inspected
	if requires_rules:
		can_file = can_file and rules_checked
	
	if file_ticket_btn:
		file_ticket_btn.text = "✓ Filed" if ticket_filed else "📤 File Ticket"
		file_ticket_btn.disabled = ticket_filed or not can_file
	
	# Create stamp buttons only when ticket is filed
	if ticket_filed:
		_create_stamp_buttons()

## Create stamp buttons after workflow is complete
func _create_stamp_buttons() -> void:
	if not stamp_buttons:
		return
	
	# Clear existing
	for c in stamp_buttons.get_children():
		c.queue_free()
	
	var t = tickets[index]
	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 15)
	stamp_buttons.add_child(hbox)
	
	for stamp in t.get("allowed_stamps", []):
		var btn = Button.new()
		btn.text = "🔴 " + stamp if stamp == "DENIED" else "🟢 " + stamp if stamp == "APPROVED" else "🟡 " + stamp
		btn.custom_minimum_size = Vector2(130, 50)
		btn.pressed.connect(_stamp.bind(stamp))
		hbox.add_child(btn)
	
	if toast:
		toast.text = "🖋️ Ready to stamp!"

## Workflow step: Open Folder
func _on_open_folder() -> void:
	if event_active:
		return
	if not folder_opened:
		folder_opened = true
		if toast:
			toast.text = "📂 Folder opened. Review the ticket."
		_play_click()
		_update_workflow_ui()

## Workflow step: Inspect Attachment
func _on_inspect() -> void:
	if event_active:
		return
	if folder_opened and not attachment_inspected:
		attachment_inspected = true
		if toast:
			toast.text = "🔍 Attachment verified."
		_play_click()
		_update_workflow_ui()

## Workflow step: Check Rules (opens rulebook)
func _on_check_rules() -> void:
	if event_active:
		return
	_open_rulebook()

## Workflow step: File Ticket
func _on_file_ticket() -> void:
	if event_active:
		return
	# Check if all prerequisites are met
	var can_file = folder_opened
	if requires_inspect:
		can_file = can_file and attachment_inspected
	if requires_rules:
		can_file = can_file and rules_checked
	
	if can_file and not ticket_filed:
		ticket_filed = true
		if toast:
			toast.text = "📤 Ticket filed. Select your stamp."
		_play_click()
		_update_workflow_ui()

## Handle stamp click
func _stamp(name: String) -> void:
	if busy or event_active:
		return
	
	# Check if workflow is complete
	if not ticket_filed:
		# Process violation!
		contradiction += 1
		_update_meters()
		if toast:
			toast.text = "⚠️ Process violation logged. Complete the workflow first!"
		_play_error()
		_play_tremor()
		return
	
	busy = true
	var t = tickets[index]
	var outcomes = t.get("outcomes", {})
	
	if outcomes.has(name):
		var o = outcomes[name]
		
		# Get toast text (null-safe)
		var toast_id = o.get("toast_id", "")
		var toast_text_str = ""
		var dataloader = get_node_or_null("/root/DataLoader")
		if dataloader and dataloader.has_method("toast_text"):
			toast_text_str = dataloader.toast_text(toast_id)
		if toast:
			toast.text = "💬 " + toast_text_str
		
		mood += int(o.get("mood_delta", 0))
		var delta = int(o.get("contradiction_delta", 0))
		contradiction += delta
		_update_meters()
		
		# Play stamp sound
		_play_stamp(name == "APPROVED")
		
		# Reality tremor effect for high contradiction
		if delta >= 3:
			_play_glitch()
			_play_tremor()
		
		# Disable stamp buttons
		if stamp_buttons:
			for c in stamp_buttons.get_children():
				for b in c.get_children():
					if b is Button:
						b.disabled = true
		
		# Animate ticket sliding out, then show next
		await _animate_ticket_out()
		busy = false
		_show(index + 1)
	else:
		if toast:
			toast.text = "⚠️ Invalid stamp"
		_play_error()
		busy = false

## Animate ticket sliding out
func _animate_ticket_out() -> void:
	if not ticket_vbox:
		return
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(ticket_vbox, "position:x", -500, 0.25)
	await tween.finished
	
	# Reset position for next ticket
	ticket_vbox.position.x = 500
	
	# Slide in
	var tween_in = create_tween()
	tween_in.set_trans(Tween.TRANS_QUAD)
	tween_in.set_ease(Tween.EASE_OUT)
	tween_in.tween_property(ticket_vbox, "position:x", 0, 0.25)
	await tween_in.finished

## Play "reality tremor" effect - UI + 3D scene + visual overlay (respects settings)
func _play_tremor() -> void:
	# Scale effects based on settings
	var shake_scale = 1.0 if not reduce_motion else 0.3
	var effect_scale = vfx_intensity
	
	# Flash background red briefly
	if background:
		var tween = create_tween()
		var flash_color = Color(0.4, 0.1, 0.1, 0.9).lerp(original_bg_color, 1.0 - effect_scale)
		tween.tween_property(background, "color", flash_color, 0.1)
		tween.tween_property(background, "color", original_bg_color, 0.15)
	
	# Shake the VBox slightly (reduced if reduce_motion enabled)
	if vbox:
		var shake_amount = 5.0 * shake_scale
		var shake_tween = create_tween()
		shake_tween.tween_property(vbox, "position", original_vbox_pos + Vector2(-shake_amount, 0), 0.03)
		shake_tween.tween_property(vbox, "position", original_vbox_pos + Vector2(shake_amount, 0), 0.03)
		shake_tween.tween_property(vbox, "position", original_vbox_pos + Vector2(-shake_amount * 0.6, 0), 0.03)
		shake_tween.tween_property(vbox, "position", original_vbox_pos + Vector2(shake_amount * 0.6, 0), 0.03)
		shake_tween.tween_property(vbox, "position", original_vbox_pos, 0.03)
	
	# Intensify scanline overlay briefly (scaled by vfx_intensity)
	if scanline_overlay and scanline_overlay.material:
		var mat = scanline_overlay.material as ShaderMaterial
		if mat:
			var max_glitch = 0.5 * effect_scale
			var overlay_tween = create_tween()
			overlay_tween.tween_method(_set_glitch_intensity, 0.0, max_glitch, 0.1)
			overlay_tween.tween_method(_set_glitch_intensity, max_glitch, 0.0, 0.2)
	
	# Also trigger 3D tremor (null-safe, scaled)
	if office_3d and office_3d.has_method("apply_tremor"):
		office_3d.apply_tremor(0.6 * shake_scale, 0.3)

## Set glitch intensity on shader
func _set_glitch_intensity(value: float) -> void:
	if scanline_overlay and scanline_overlay.material:
		var mat = scanline_overlay.material as ShaderMaterial
		if mat:
			mat.set_shader_parameter("glitch_intensity", value)

## Sound effect helpers (null-safe)
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

## Update meter display
func _update_meters() -> void:
	if mood_value:
		mood_value.text = "Mood: %+d" % mood
	if contradiction_value:
		contradiction_value.text = "Contradiction: %d" % contradiction

## Shift complete
func _complete() -> void:
	# Stop event system
	if shift_events and shift_events.has_method("stop"):
		shift_events.stop()
	
	# Unlock next shift (null-safe)
	var save_node = _get_save()
	if save_node and shift_number < 10:
		if save_node.has_method("unlock_shift"):
			save_node.unlock_shift(shift_number + 1)
		if save_node.has_method("write_save"):
			save_node.write_save()
	
	# Hide workflow bar (null-safe)
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
		progress.text = "Final — Mood: %+d | Contradiction: %d" % [mood, contradiction]
	
	if stamp_buttons:
		for c in stamp_buttons.get_children():
			c.queue_free()
		
		# Add next shift button if not at shift 10
		if shift_number < 10:
			var next_btn = Button.new()
			next_btn.text = "▶ Next Shift (%02d)" % (shift_number + 1)
			next_btn.custom_minimum_size = Vector2(200, 45)
			next_btn.pressed.connect(_next_shift)
			stamp_buttons.add_child(next_btn)
	
	if back_button:
		back_button.visible = true

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

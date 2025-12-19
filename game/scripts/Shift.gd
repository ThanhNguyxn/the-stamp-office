extends Control
## Shift - Desk job workflow gameplay with 4-step ticket processing

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
var original_bg_color: Color
var original_vbox_pos: Vector2

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
	original_bg_color = background.color
	original_vbox_pos = vbox.position
	
	# Get reference to Office3D scene (null-safe)
	if office_viewport and office_viewport.get_child_count() > 0:
		office_3d = office_viewport.get_child(0)
	
	# Wire main buttons
	back_button.pressed.connect(_back)
	back_button.visible = false
	rulebook_button.pressed.connect(_open_rulebook)
	rulebook_close_button.pressed.connect(_close_rulebook)
	
	# Wire workflow buttons
	open_folder_btn.pressed.connect(_on_open_folder)
	inspect_btn.pressed.connect(_on_inspect)
	check_rules_btn.pressed.connect(_on_check_rules)
	file_ticket_btn.pressed.connect(_on_file_ticket)
	
	toast.text = ""
	
	# Get selected shift from GameState
	shift_number = GameState.selected_shift
	header.text = "SHIFT %02d" % shift_number
	
	# Load tickets
	tickets = DataLoader.load_shift(shift_number)
	
	# Populate rulebook with this shift's rules
	_populate_rulebook()
	
	# Show rulebook automatically on shift start
	_open_rulebook()
	
	if tickets.size() > 0:
		_show(0)
	else:
		ticket_text.text = "No tickets found"
		attachment.text = "Run: python tools/sync_game_data.py"
		_update_workflow_ui()

## Populate rulebook popup with rules for current shift
func _populate_rulebook() -> void:
	var rules = DataLoader.rules_for_shift(shift_number)
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
	rulebook_popup.visible = true
	# Mark rules as checked for workflow
	if not rules_checked:
		rules_checked = true
		_update_workflow_ui()

## Close rulebook popup
func _close_rulebook() -> void:
	rulebook_popup.visible = false

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
	
	# Display ticket content
	ticket_text.text = t.get("text", "")
	var att = t.get("attachment", "N/A")
	attachment.text = "📎 " + att if att != "" else "📎 N/A"
	progress.text = "Ticket %d / %d" % [i + 1, tickets.size()]
	toast.text = "📁 Please follow the workflow steps"
	_update_meters()
	_update_workflow_ui()
	
	# Clear old stamp buttons (will be created when workflow is complete)
	for c in stamp_buttons.get_children():
		c.queue_free()

## Update workflow button states and create stamp buttons when ready
func _update_workflow_ui() -> void:
	# Update button visual states (completed steps get a checkmark)
	open_folder_btn.text = "✓ Folder Opened" if folder_opened else "📁 Open Folder"
	open_folder_btn.disabled = folder_opened
	
	# Inspect requires folder to be opened first
	if requires_inspect:
		inspect_btn.visible = true
		inspect_btn.text = "✓ Inspected" if attachment_inspected else "🔍 Inspect"
		inspect_btn.disabled = attachment_inspected or not folder_opened
	else:
		inspect_btn.visible = false
		attachment_inspected = true  # Auto-complete if not required
	
	# Check Rules requires folder opened
	if requires_rules:
		check_rules_btn.visible = true
		check_rules_btn.text = "✓ Rules OK" if rules_checked else "📋 Check Rules"
		check_rules_btn.disabled = rules_checked or not folder_opened
	else:
		check_rules_btn.visible = false
		# Don't auto-complete rules_checked - let user open rulebook if they want
	
	# File Ticket requires all previous steps
	var can_file = folder_opened
	if requires_inspect:
		can_file = can_file and attachment_inspected
	if requires_rules:
		can_file = can_file and rules_checked
	
	file_ticket_btn.text = "✓ Filed" if ticket_filed else "📤 File Ticket"
	file_ticket_btn.disabled = ticket_filed or not can_file
	
	# Create stamp buttons only when ticket is filed
	if ticket_filed:
		_create_stamp_buttons()

## Create stamp buttons after workflow is complete
func _create_stamp_buttons() -> void:
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
	
	toast.text = "🖋️ Ready to stamp!"

## Workflow step: Open Folder
func _on_open_folder() -> void:
	if not folder_opened:
		folder_opened = true
		toast.text = "📂 Folder opened. Review the ticket."
		_update_workflow_ui()

## Workflow step: Inspect Attachment
func _on_inspect() -> void:
	if folder_opened and not attachment_inspected:
		attachment_inspected = true
		toast.text = "🔍 Attachment verified."
		_update_workflow_ui()

## Workflow step: Check Rules (opens rulebook)
func _on_check_rules() -> void:
	_open_rulebook()

## Workflow step: File Ticket
func _on_file_ticket() -> void:
	# Check if all prerequisites are met
	var can_file = folder_opened
	if requires_inspect:
		can_file = can_file and attachment_inspected
	if requires_rules:
		can_file = can_file and rules_checked
	
	if can_file and not ticket_filed:
		ticket_filed = true
		toast.text = "📤 Ticket filed. Select your stamp."
		_update_workflow_ui()

## Handle stamp click
func _stamp(name: String) -> void:
	if busy:
		return
	
	# Check if workflow is complete
	if not ticket_filed:
		# Process violation!
		contradiction += 1
		_update_meters()
		toast.text = "⚠️ Process violation logged. Complete the workflow first!"
		_play_tremor()
		return
	
	busy = true
	var t = tickets[index]
	var outcomes = t.get("outcomes", {})
	
	if outcomes.has(name):
		var o = outcomes[name]
		toast.text = "💬 " + DataLoader.toast_text(o.get("toast_id", ""))
		mood += int(o.get("mood_delta", 0))
		var delta = int(o.get("contradiction_delta", 0))
		contradiction += delta
		_update_meters()
		
		# Reality tremor effect for high contradiction
		if delta >= 3:
			_play_tremor()
		
		# Disable stamp buttons
		for c in stamp_buttons.get_children():
			for b in c.get_children():
				if b is Button:
					b.disabled = true
		
		# Animate ticket sliding out, then show next
		await _animate_ticket_out()
		busy = false
		_show(index + 1)
	else:
		toast.text = "⚠️ Invalid stamp"
		busy = false

## Animate ticket sliding out
func _animate_ticket_out() -> void:
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

## Play "reality tremor" effect - UI + 3D scene
func _play_tremor() -> void:
	# Flash background red briefly
	var tween = create_tween()
	tween.tween_property(background, "color", Color(0.4, 0.1, 0.1, 0.9), 0.1)
	tween.tween_property(background, "color", original_bg_color, 0.15)
	
	# Shake the VBox slightly
	var shake_tween = create_tween()
	shake_tween.tween_property(vbox, "position", original_vbox_pos + Vector2(-5, 0), 0.03)
	shake_tween.tween_property(vbox, "position", original_vbox_pos + Vector2(5, 0), 0.03)
	shake_tween.tween_property(vbox, "position", original_vbox_pos + Vector2(-3, 0), 0.03)
	shake_tween.tween_property(vbox, "position", original_vbox_pos + Vector2(3, 0), 0.03)
	shake_tween.tween_property(vbox, "position", original_vbox_pos, 0.03)
	
	# Also trigger 3D tremor (null-safe)
	if office_3d and office_3d.has_method("apply_tremor"):
		office_3d.apply_tremor(0.6, 0.3)

## Update meter display
func _update_meters() -> void:
	mood_value.text = "Mood: %+d" % mood
	contradiction_value.text = "Contradiction: %d" % contradiction

## Shift complete
func _complete() -> void:
	# Hide workflow bar
	open_folder_btn.visible = false
	inspect_btn.visible = false
	check_rules_btn.visible = false
	file_ticket_btn.visible = false
	
	ticket_text.text = "SHIFT %02d COMPLETE" % shift_number
	attachment.text = "Thank you for your service."
	toast.text = "🎉 All tickets processed!"
	progress.text = "Final — Mood: %+d | Contradiction: %d" % [mood, contradiction]
	
	for c in stamp_buttons.get_children():
		c.queue_free()
	
	# Add next shift button if not at shift 10
	if shift_number < 10:
		var next_btn = Button.new()
		next_btn.text = "▶ Next Shift (%02d)" % (shift_number + 1)
		next_btn.custom_minimum_size = Vector2(200, 45)
		next_btn.pressed.connect(_next_shift)
		stamp_buttons.add_child(next_btn)
	
	back_button.visible = true

func _next_shift() -> void:
	GameState.selected_shift = shift_number + 1
	get_tree().reload_current_scene()

func _back() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

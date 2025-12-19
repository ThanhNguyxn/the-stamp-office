extends Control
## Shift - Gameplay controller with rulebook popup and tremor effects

# UI references
@onready var background: ColorRect = $Background
@onready var vbox: VBoxContainer = $VBox
@onready var header: Label = $VBox/HeaderRow/Header
@onready var rulebook_button: Button = $VBox/HeaderRow/RulebookButton
@onready var ticket_text: Label = $VBox/TicketPanel/TicketVBox/TicketText
@onready var attachment: Label = $VBox/TicketPanel/TicketVBox/Attachment
@onready var stamp_buttons: VBoxContainer = $VBox/StampButtons
@onready var toast: Label = $VBox/ToastPanel/Toast
@onready var mood_value: Label = $VBox/MetersBox/MoodValue
@onready var contradiction_value: Label = $VBox/MetersBox/ContradictionValue
@onready var progress: Label = $VBox/Progress
@onready var back_button: Button = $VBox/BackButton

# Rulebook popup references
@onready var rulebook_popup: PanelContainer = $RulebookPopup
@onready var rules_text: Label = $RulebookPopup/VBox/Scroll/RulesText
@onready var rulebook_close_button: Button = $RulebookPopup/VBox/RulebookCloseButton

# Game state
var shift_number: int = 1
var tickets: Array = []
var index: int = 0
var mood: int = 0
var contradiction: int = 0
var busy: bool = false
var original_bg_color: Color
var original_vbox_pos: Vector2

func _ready() -> void:
	# Store original values for effects
	original_bg_color = background.color
	original_vbox_pos = vbox.position
	
	# Wire buttons
	back_button.pressed.connect(_back)
	back_button.visible = false
	rulebook_button.pressed.connect(_open_rulebook)
	rulebook_close_button.pressed.connect(_close_rulebook)
	
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

## Open rulebook popup
func _open_rulebook() -> void:
	rulebook_popup.visible = true

## Close rulebook popup
func _close_rulebook() -> void:
	rulebook_popup.visible = false

## Show a ticket
func _show(i: int) -> void:
	if i >= tickets.size():
		_complete()
		return
	index = i
	var t = tickets[i]
	ticket_text.text = t.get("text", "")
	attachment.text = "📎 " + t.get("attachment", "N/A")
	progress.text = "Ticket %d / %d" % [i + 1, tickets.size()]
	toast.text = ""
	_update_meters()
	
	# Clear old buttons
	for c in stamp_buttons.get_children():
		c.queue_free()
	
	# Create stamp buttons
	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 15)
	stamp_buttons.add_child(hbox)
	for stamp in t.get("allowed_stamps", []):
		var btn = Button.new()
		btn.text = stamp
		btn.custom_minimum_size = Vector2(110, 45)
		btn.pressed.connect(_stamp.bind(stamp))
		hbox.add_child(btn)

## Handle stamp click
func _stamp(name: String) -> void:
	if busy:
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
		
		for c in stamp_buttons.get_children():
			for b in c.get_children():
				if b is Button:
					b.disabled = true
		await get_tree().create_timer(1.0).timeout
		busy = false
		_show(index + 1)
	else:
		toast.text = "⚠️ Invalid stamp"
		busy = false

## Play "reality tremor" effect - background flash + subtle shake
func _play_tremor() -> void:
	# Flash background red briefly
	var tween = create_tween()
	tween.tween_property(background, "color", Color(0.4, 0.1, 0.1, 1), 0.1)
	tween.tween_property(background, "color", original_bg_color, 0.15)
	
	# Shake the VBox slightly
	var shake_tween = create_tween()
	shake_tween.tween_property(vbox, "position", original_vbox_pos + Vector2(-5, 0), 0.03)
	shake_tween.tween_property(vbox, "position", original_vbox_pos + Vector2(5, 0), 0.03)
	shake_tween.tween_property(vbox, "position", original_vbox_pos + Vector2(-3, 0), 0.03)
	shake_tween.tween_property(vbox, "position", original_vbox_pos + Vector2(3, 0), 0.03)
	shake_tween.tween_property(vbox, "position", original_vbox_pos, 0.03)

## Update meter display
func _update_meters() -> void:
	mood_value.text = "Mood: %+d" % mood
	contradiction_value.text = "Contradiction: %d" % contradiction

## Shift complete
func _complete() -> void:
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

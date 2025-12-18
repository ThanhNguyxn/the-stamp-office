extends Control
## Shift - Gameplay controller for any shift

@onready var header: Label = $VBox/Header
@onready var ticket_text: Label = $VBox/TicketPanel/TicketVBox/TicketText
@onready var attachment: Label = $VBox/TicketPanel/TicketVBox/Attachment
@onready var stamp_buttons: VBoxContainer = $VBox/StampButtons
@onready var toast: Label = $VBox/ToastPanel/Toast
@onready var mood_value: Label = $VBox/MetersBox/MoodValue
@onready var contradiction_value: Label = $VBox/MetersBox/ContradictionValue
@onready var progress: Label = $VBox/Progress
@onready var back_button: Button = $VBox/BackButton

var shift_number: int = 1
var tickets: Array = []
var index: int = 0
var mood: int = 0
var contradiction: int = 0
var busy: bool = false

func _ready() -> void:
	back_button.pressed.connect(_back)
	back_button.visible = false
	toast.text = ""
	
	# Get selected shift from GameState
	shift_number = GameState.selected_shift
	header.text = "SHIFT %02d" % shift_number
	
	tickets = DataLoader.load_shift(shift_number)
	if tickets.size() > 0:
		_show(0)
	else:
		ticket_text.text = "No tickets found"
		attachment.text = "Run: python tools/sync_game_data.py"

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
		contradiction += int(o.get("contradiction_delta", 0))
		_update_meters()
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

func _update_meters() -> void:
	mood_value.text = "Mood: %+d" % mood
	contradiction_value.text = "Contradiction: %d" % contradiction

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

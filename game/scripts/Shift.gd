extends Control
## Shift - Handles the shift gameplay loop

@onready var ticket_text_label: Label = $VBoxContainer/TicketPanel/VBoxContainer/TicketText
@onready var attachment_label: Label = $VBoxContainer/TicketPanel/VBoxContainer/AttachmentText
@onready var stamp_container: HBoxContainer = $VBoxContainer/StampContainer
@onready var toast_label: Label = $VBoxContainer/ToastPanel/ToastText
@onready var mood_label: Label = $VBoxContainer/MetersPanel/HBoxContainer/MoodLabel
@onready var contradiction_label: Label = $VBoxContainer/MetersPanel/HBoxContainer/ContradictionLabel
@onready var progress_label: Label = $VBoxContainer/ProgressLabel
@onready var back_button: Button = $VBoxContainer/BackButton

var tickets: Array = []
var current_ticket_index: int = 0
var mood: int = 0
var contradiction: int = 0

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	back_button.visible = false
	_load_shift()

func _load_shift() -> void:
	tickets = DataLoader.load_shift01()
	if tickets.size() > 0:
		_display_ticket(0)
	else:
		ticket_text_label.text = "No tickets found!"
		attachment_label.text = "Check data path."

func _display_ticket(index: int) -> void:
	if index >= tickets.size():
		_shift_complete()
		return
	
	current_ticket_index = index
	var ticket = tickets[index]
	
	# Display ticket info
	ticket_text_label.text = ticket.get("text", "")
	attachment_label.text = "📎 " + ticket.get("attachment", "")
	progress_label.text = "Ticket %d / %d" % [index + 1, tickets.size()]
	
	# Update meters
	_update_meters()
	
	# Clear old stamp buttons
	for child in stamp_container.get_children():
		child.queue_free()
	
	# Create stamp buttons
	var allowed_stamps = ticket.get("allowed_stamps", [])
	for stamp in allowed_stamps:
		var btn = Button.new()
		btn.text = stamp
		btn.custom_minimum_size = Vector2(120, 50)
		btn.pressed.connect(_on_stamp_pressed.bind(stamp))
		stamp_container.add_child(btn)
	
	# Clear toast
	toast_label.text = ""

func _on_stamp_pressed(stamp: String) -> void:
	var ticket = tickets[current_ticket_index]
	var outcomes = ticket.get("outcomes", {})
	
	if outcomes.has(stamp):
		var outcome = outcomes[stamp]
		
		# Get toast text
		var toast_id = outcome.get("toast_id", "")
		var toast_text = DataLoader.toast_text(toast_id)
		toast_label.text = "💬 " + toast_text
		
		# Apply deltas
		mood += outcome.get("mood_delta", 0)
		contradiction += outcome.get("contradiction_delta", 0)
		_update_meters()
		
		# Brief delay then next ticket
		await get_tree().create_timer(1.5).timeout
		_display_ticket(current_ticket_index + 1)
	else:
		toast_label.text = "⚠️ Invalid stamp!"

func _update_meters() -> void:
	mood_label.text = "Mood: %+d" % mood
	contradiction_label.text = "Contradiction: %d" % contradiction

func _shift_complete() -> void:
	ticket_text_label.text = "SHIFT COMPLETE"
	attachment_label.text = "Thank you for your service."
	toast_label.text = "🎉 Shift 01 finished!"
	progress_label.text = "Final Stats"
	
	# Clear stamp buttons
	for child in stamp_container.get_children():
		child.queue_free()
	
	# Show back button
	back_button.visible = true

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

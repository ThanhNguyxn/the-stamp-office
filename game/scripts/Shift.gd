extends Control
## Shift - Gameplay controller for processing tickets

@onready var ticket_text_label: Label = $VBoxContainer/TicketPanel/VBoxContainer/TicketText
@onready var attachment_label: Label = $VBoxContainer/TicketPanel/VBoxContainer/AttachmentText
@onready var stamp_container: HBoxContainer = $VBoxContainer/StampContainer
@onready var toast_label: Label = $VBoxContainer/ToastPanel/ToastText
@onready var mood_label: Label = $VBoxContainer/MetersPanel/HBoxContainer/MoodLabel
@onready var contradiction_label: Label = $VBoxContainer/MetersPanel/HBoxContainer/ContradictionLabel
@onready var progress_label: Label = $VBoxContainer/ProgressLabel
@onready var back_button: Button = $VBoxContainer/BackButton

var tickets: Array = []
var current_index: int = 0
var mood: int = 0
var contradiction: int = 0
var is_processing: bool = false

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	back_button.visible = false
	toast_label.text = ""
	_load_shift()

func _load_shift() -> void:
	tickets = DataLoader.load_shift(1)
	if tickets.size() > 0:
		_show_ticket(0)
	else:
		ticket_text_label.text = "No tickets found!"
		attachment_label.text = "Check that data/ folder exists in game/"
		progress_label.text = "Error loading shift data"

func _show_ticket(index: int) -> void:
	if index >= tickets.size():
		_shift_complete()
		return
	
	current_index = index
	var ticket = tickets[index]
	
	# Display ticket content
	ticket_text_label.text = ticket.get("text", "")
	attachment_label.text = "📎 " + ticket.get("attachment", "N/A")
	progress_label.text = "Ticket %d / %d" % [index + 1, tickets.size()]
	toast_label.text = ""
	
	# Update meter displays
	_update_meters()
	
	# Clear existing stamp buttons
	for child in stamp_container.get_children():
		child.queue_free()
	
	# Create stamp buttons from allowed_stamps
	var allowed = ticket.get("allowed_stamps", [])
	for stamp_name in allowed:
		var btn = Button.new()
		btn.text = stamp_name
		btn.custom_minimum_size = Vector2(120, 50)
		btn.pressed.connect(_on_stamp_clicked.bind(stamp_name))
		stamp_container.add_child(btn)

func _on_stamp_clicked(stamp_name: String) -> void:
	if is_processing:
		return
	is_processing = true
	
	var ticket = tickets[current_index]
	var outcomes = ticket.get("outcomes", {})
	
	if outcomes.has(stamp_name):
		var outcome = outcomes[stamp_name]
		
		# Get and show toast
		var toast_id = outcome.get("toast_id", "")
		var text = DataLoader.toast_text(toast_id)
		toast_label.text = "💬 " + text
		
		# Apply deltas
		mood += int(outcome.get("mood_delta", 0))
		contradiction += int(outcome.get("contradiction_delta", 0))
		_update_meters()
		
		# Disable buttons during delay
		for child in stamp_container.get_children():
			if child is Button:
				child.disabled = true
		
		# Wait then advance
		await get_tree().create_timer(1.2).timeout
		is_processing = false
		_show_ticket(current_index + 1)
	else:
		toast_label.text = "⚠️ Invalid stamp!"
		is_processing = false

func _update_meters() -> void:
	mood_label.text = "Mood: %+d" % mood
	contradiction_label.text = "Contradiction: %d" % contradiction

func _shift_complete() -> void:
	ticket_text_label.text = "SHIFT COMPLETE"
	attachment_label.text = "Thank you for your service."
	toast_label.text = "🎉 You processed all tickets!"
	progress_label.text = "Final — Mood: %+d | Contradiction: %d" % [mood, contradiction]
	
	# Clear stamp buttons
	for child in stamp_container.get_children():
		child.queue_free()
	
	# Show back button
	back_button.visible = true

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

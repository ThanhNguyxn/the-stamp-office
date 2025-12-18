extends Control
## Shift - Placeholder for shift gameplay
## JSON loading will be added in next commit

@onready var ticket_text_label: Label = $VBoxContainer/TicketPanel/VBoxContainer/TicketText
@onready var attachment_label: Label = $VBoxContainer/TicketPanel/VBoxContainer/AttachmentText
@onready var toast_label: Label = $VBoxContainer/ToastPanel/ToastText
@onready var mood_label: Label = $VBoxContainer/MetersPanel/HBoxContainer/MoodLabel
@onready var contradiction_label: Label = $VBoxContainer/MetersPanel/HBoxContainer/ContradictionLabel
@onready var back_button: Button = $VBoxContainer/BackButton

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	
	# Scaffold placeholder - shows that UI is working
	ticket_text_label.text = "Prototype loaded!"
	attachment_label.text = "📎 UI scaffold complete"
	toast_label.text = "💬 JSON loading coming next"
	mood_label.text = "Mood: +0"
	contradiction_label.text = "Contradiction: 0"

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

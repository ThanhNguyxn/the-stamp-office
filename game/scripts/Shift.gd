extends Control
## Shift - Scaffold placeholder
## JSON loading will be added in next commit

@onready var ticket_text: Label = $VBox/TicketPanel/TicketVBox/TicketText
@onready var attachment: Label = $VBox/TicketPanel/TicketVBox/Attachment
@onready var stamp_buttons: VBoxContainer = $VBox/StampButtons
@onready var toast: Label = $VBox/ToastPanel/Toast
@onready var mood_value: Label = $VBox/MetersBox/MoodValue
@onready var contradiction_value: Label = $VBox/MetersBox/ContradictionValue
@onready var back_button: Button = $VBox/BackButton

func _ready() -> void:
	back_button.pressed.connect(_on_back)
	
	# Scaffold placeholder text
	ticket_text.text = "Prototype loaded!"
	attachment.text = "📎 UI scaffold complete"
	toast.text = "💬 JSON loading next"
	mood_value.text = "Mood: +0"
	contradiction_value.text = "Contradiction: 0"

func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

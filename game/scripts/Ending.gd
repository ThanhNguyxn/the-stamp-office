extends Control
## Ending - Displays ending screen based on player choices

@onready var title: Label = $VBox/Title
@onready var epilogue_text: Label = $VBox/EpilogueText
@onready var credits: Label = $VBox/Credits
@onready var menu_button: Button = $VBox/MenuButton
@onready var background: ColorRect = $Background

# Ending data
const ENDINGS = {
	"compliance": {
		"title": "CLOCK OUT",
		"text": "You stamp the final ticket. The lights dim. A slow, warm fade.\nThe intercom thanks you for your service.\nYour desk lamp turns off.\n\nYou were a model employee.\nThe Office is pleased.\nReality remains... stable enough.",
		"final": "\"Thank you for your service. Clock out approved.\"",
		"color": Color(0.15, 0.12, 0.08)
	},
	"dissolution": {
		"title": "OFFICIAL",
		"text": "You stamp the final ticket. The walls shimmer.\nThe rules on the board scramble. Your stamp glows.\nThe Office speaks directly to you —\nnot through the intercom, but through you.\n\nYou broke protocol. The system fractures.\nYou are no longer an employee.\nYou are something else now.",
		"final": "\"You were never an employee. You were always The Office.\"",
		"color": Color(0.12, 0.05, 0.15)
	},
	"transcendence": {
		"title": "NOT A THING",
		"text": "You stamp the third ticket. Silence.\nThe screen goes white. Elevator music plays, increasingly distorted.\nThe Office unravels. You see something you shouldn't.\n\nA door appears.\nIt was always there.\nYou just couldn't see it.",
		"final": "\"████████ ACCESSED. Please proceed.\"",
		"color": Color(0.02, 0.02, 0.02)
	}
}

var ending_type: String = "compliance"

func _ready() -> void:
	# Get ending type from GameState
	var gamestate = get_node_or_null("/root/GameState")
	if gamestate and "ending_type" in gamestate:
		ending_type = str(gamestate.ending_type)
	
	# Apply ending
	_show_ending()
	
	# Wire button
	if menu_button:
		menu_button.pressed.connect(_on_menu_pressed)

func _show_ending() -> void:
	var data = ENDINGS.get(ending_type, ENDINGS["compliance"])
	
	if title:
		title.text = data.get("title", "ENDING")
	
	if epilogue_text:
		epilogue_text.text = data.get("text", "") + "\n\n" + data.get("final", "")
	
	if background:
		background.color = data.get("color", Color(0.02, 0.02, 0.03))
	
	if credits:
		credits.text = """THE STAMP OFFICE

A game about paperwork and existential dread.

Created with Godot Engine.

Thank you for playing."""
	
	# Save ending
	var save_node = get_node_or_null("/root/Save")
	if save_node and save_node.has_method("set_ending"):
		save_node.set_ending(ending_type)
	
	# Animate
	_animate_in()

func _animate_in() -> void:
	if title:
		title.modulate.a = 0
		var tween = create_tween()
		tween.tween_property(title, "modulate:a", 1.0, 2.0)
	
	if epilogue_text:
		epilogue_text.modulate.a = 0
		var tween2 = create_tween()
		tween2.tween_interval(1.5)
		tween2.tween_property(epilogue_text, "modulate:a", 1.0, 3.0)
	
	if credits:
		credits.modulate.a = 0
		var tween3 = create_tween()
		tween3.tween_interval(4.0)
		tween3.tween_property(credits, "modulate:a", 1.0, 2.0)
	
	if menu_button:
		menu_button.modulate.a = 0
		menu_button.disabled = true
		var tween4 = create_tween()
		tween4.tween_interval(6.0)
		tween4.tween_property(menu_button, "modulate:a", 1.0, 1.0)
		tween4.tween_callback(_enable_button)

func _enable_button() -> void:
	if menu_button:
		menu_button.disabled = false

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

extends Control
## Main Menu

@onready var start_button: Button = $VBox/StartButton
@onready var quit_button: Button = $VBox/QuitButton

func _ready() -> void:
	start_button.pressed.connect(_on_start)
	quit_button.pressed.connect(_on_quit)

func _on_start() -> void:
	get_tree().change_scene_to_file("res://scenes/Shift.tscn")

func _on_quit() -> void:
	get_tree().quit()

extends Control
## Main Menu with Shift Selector

@onready var shift_select: OptionButton = $VBox/ShiftBox/ShiftSelect
@onready var start_button: Button = $VBox/StartButton
@onready var quit_button: Button = $VBox/QuitButton

func _ready() -> void:
	# Populate shift selector
	for i in range(1, 11):
		shift_select.add_item("Shift %02d" % i, i)
	shift_select.selected = 0
	
	start_button.pressed.connect(_on_start)
	quit_button.pressed.connect(_on_quit)

func _on_start() -> void:
	var shift_num = shift_select.get_selected_id()
	if shift_num == 0:
		shift_num = 1
	# Store selected shift in autoload for Shift scene to read
	GameState.selected_shift = shift_num
	get_tree().change_scene_to_file("res://scenes/Shift.tscn")

func _on_quit() -> void:
	get_tree().quit()

extends Control
## Main Menu - Professional UI with Shift Selector, Settings, Credits
## The Stamp Office - A Bureaucratic Horror Experience

# Shift selector
@onready var shift_prev: Button = %ShiftPrev
@onready var shift_next: Button = %ShiftNext
@onready var shift_display: Label = %ShiftDisplay
@onready var shift_progress: ProgressBar = %ShiftProgress

# Main buttons
@onready var start_button: Button = %StartButton
@onready var settings_button: Button = %SettingsButton
@onready var credits_button: Button = %CreditsButton
@onready var quit_button: Button = %QuitButton
@onready var reset_button: Button = %ResetButton

# Popups
@onready var settings_popup: Control = $SettingsLayer/SettingsPopup
@onready var settings_panel = $SettingsLayer/SettingsPopup/Settings
@onready var credits_popup: Control = $CreditsLayer/CreditsPopup
@onready var close_credits: Button = $CreditsLayer/CreditsPopup/CreditsPanel/Margin/VBox/CloseCredits

# Tips
@onready var tips_label: Label = $TipsLabel

# Confirm dialog
@onready var confirm_dialog: ConfirmationDialog = $ConfirmDialog

# Animation
@onready var anim_player: AnimationPlayer = $AnimationPlayer

# State
var current_shift: int = 1
var max_unlocked_shift: int = 1

# Tips to cycle through
var tips: Array[String] = [
	"💡 TIP: Read the rules carefully...",
	"💡 TIP: Some stamps are more equal than others",
	"💡 TIP: The clock is always watching",
	"💡 TIP: Don't trust the printer",
	"💡 TIP: Manager's door should stay closed",
	"💡 TIP: The fridge hums with secrets",
	"💡 TIP: Archives hold forgotten truths",
	"💡 TIP: Break room coffee is... suspicious",
]
var current_tip_index: int = 0
var tip_timer: float = 0.0

func _ready() -> void:
	# Load save data
	var save_node = _get_save()
	if save_node:
		save_node.load_save()
		if "unlocked_max_shift" in save_node:
			max_unlocked_shift = clampi(int(save_node.unlocked_max_shift), 1, 10)
	
	# Set initial shift to highest unlocked
	current_shift = max_unlocked_shift
	_update_shift_display()
	
	# Connect buttons
	_connect_buttons()
	
	# Start tip cycling
	_randomize_tip()
	
	# Fade in effect
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)

func _process(delta: float) -> void:
	# Cycle tips every 8 seconds
	tip_timer += delta
	if tip_timer >= 8.0:
		tip_timer = 0.0
		_next_tip()

func _connect_buttons() -> void:
	# Shift navigation
	if shift_prev:
		shift_prev.pressed.connect(_on_shift_prev)
	if shift_next:
		shift_next.pressed.connect(_on_shift_next)
	
	# Main buttons
	if start_button:
		start_button.pressed.connect(_on_start)
		start_button.mouse_entered.connect(_on_button_hover.bind(start_button))
	if settings_button:
		settings_button.pressed.connect(_open_settings)
		settings_button.mouse_entered.connect(_on_button_hover.bind(settings_button))
	if credits_button:
		credits_button.pressed.connect(_open_credits)
		credits_button.mouse_entered.connect(_on_button_hover.bind(credits_button))
	if quit_button:
		quit_button.pressed.connect(_on_quit)
		quit_button.mouse_entered.connect(_on_button_hover.bind(quit_button))
	if reset_button:
		reset_button.pressed.connect(_on_reset_pressed)
	
	# Credits close
	if close_credits:
		close_credits.pressed.connect(_close_credits)
	
	# Settings panel close callback
	if settings_panel and settings_panel.has_signal("close_requested"):
		settings_panel.close_requested.connect(_close_settings)
	
	# Confirm dialog
	if confirm_dialog:
		confirm_dialog.confirmed.connect(_confirm_reset)
		confirm_dialog.canceled.connect(_cancel_reset)

## Button hover effect
func _on_button_hover(btn: Button) -> void:
	# Quick scale pulse
	var tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(1.02, 1.02), 0.1)
	tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1)

## Update shift display
func _update_shift_display() -> void:
	if shift_display:
		shift_display.text = "SHIFT %02d" % current_shift
	
	if shift_progress:
		shift_progress.value = current_shift
		shift_progress.max_value = 10
	
	# Update button states
	if shift_prev:
		shift_prev.disabled = current_shift <= 1
		shift_prev.modulate.a = 0.3 if current_shift <= 1 else 1.0
	if shift_next:
		shift_next.disabled = current_shift >= max_unlocked_shift
		shift_next.modulate.a = 0.3 if current_shift >= max_unlocked_shift else 1.0

## Navigate shifts
func _on_shift_prev() -> void:
	if current_shift > 1:
		current_shift -= 1
		_update_shift_display()
		_animate_shift_change()

func _on_shift_next() -> void:
	if current_shift < max_unlocked_shift:
		current_shift += 1
		_update_shift_display()
		_animate_shift_change()

func _animate_shift_change() -> void:
	if shift_display:
		var tween = create_tween()
		tween.tween_property(shift_display, "modulate:a", 0.5, 0.05)
		tween.tween_property(shift_display, "modulate:a", 1.0, 0.1)

## Tips management
func _randomize_tip() -> void:
	current_tip_index = randi() % tips.size()
	_show_tip()

func _next_tip() -> void:
	current_tip_index = (current_tip_index + 1) % tips.size()
	_show_tip()

func _show_tip() -> void:
	if tips_label:
		var tween = create_tween()
		tween.tween_property(tips_label, "modulate:a", 0.0, 0.3)
		tween.tween_callback(func(): tips_label.text = tips[current_tip_index])
		tween.tween_property(tips_label, "modulate:a", 1.0, 0.3)

## Open settings
func _open_settings() -> void:
	if settings_popup:
		settings_popup.visible = true
		# Fade in
		settings_popup.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(settings_popup, "modulate:a", 1.0, 0.2)

func _close_settings() -> void:
	if settings_popup:
		var tween = create_tween()
		tween.tween_property(settings_popup, "modulate:a", 0.0, 0.15)
		tween.tween_callback(func(): settings_popup.visible = false)

## Open credits
func _open_credits() -> void:
	if credits_popup:
		credits_popup.visible = true
		credits_popup.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(credits_popup, "modulate:a", 1.0, 0.2)

func _close_credits() -> void:
	if credits_popup:
		var tween = create_tween()
		tween.tween_property(credits_popup, "modulate:a", 0.0, 0.15)
		tween.tween_callback(func(): credits_popup.visible = false)

## Reset progress
func _on_reset_pressed() -> void:
	if confirm_dialog:
		confirm_dialog.popup_centered()

func _confirm_reset() -> void:
	var save_node = _get_save()
	if save_node:
		if save_node.has_method("reset_progress"):
			save_node.reset_progress()
		if save_node.has_method("write_save"):
			save_node.write_save()
	
	max_unlocked_shift = 1
	current_shift = 1
	_update_shift_display()

func _cancel_reset() -> void:
	pass

## Start game
func _on_start() -> void:
	# Store selected shift in autoload
	var gamestate = get_node_or_null("/root/GameState")
	if gamestate and "selected_shift" in gamestate:
		gamestate.selected_shift = current_shift
	
	# Fade out and transition
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): get_tree().change_scene_to_file("res://scenes/Shift.tscn"))

## Quit game
func _on_quit() -> void:
	# Fade out
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): get_tree().quit())

## Get Save autoload node (null-safe)
func _get_save() -> Node:
	var save_node = get_node_or_null("/root/Save")
	if save_node:
		return save_node
	if Engine.has_singleton("Save"):
		return Engine.get_singleton("Save")
	return null

## Handle input for closing popups with ESC
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if settings_popup and settings_popup.visible:
			_close_settings()
			get_viewport().set_input_as_handled()
		elif credits_popup and credits_popup.visible:
			_close_credits()
			get_viewport().set_input_as_handled()

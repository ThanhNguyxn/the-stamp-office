extends Control
## Main Menu with Shift Selector, Settings, and Progression

@onready var shift_select: OptionButton = $VBox/ShiftBox/ShiftSelect
@onready var start_button: Button = $VBox/StartButton
@onready var settings_button: Button = $VBox/ButtonRow/SettingsButton
@onready var quit_button: Button = $VBox/ButtonRow/QuitButton
@onready var reset_button: Button = $VBox/ResetButton
@onready var progress_label: Label = $VBox/ProgressLabel

# Settings popup
@onready var settings_popup: PanelContainer = $SettingsPopup
@onready var sfx_check: CheckBox = $SettingsPopup/VBox/SfxCheck
@onready var events_check: CheckBox = $SettingsPopup/VBox/EventsCheck
@onready var motion_check: CheckBox = $SettingsPopup/VBox/MotionCheck
@onready var vfx_slider: HSlider = $SettingsPopup/VBox/VfxBox/VfxSlider
@onready var save_settings_btn: Button = $SettingsPopup/VBox/ButtonRow/SaveButton
@onready var close_settings_btn: Button = $SettingsPopup/VBox/ButtonRow/CloseButton

# Confirm dialog
@onready var confirm_dialog: PanelContainer = $ConfirmDialog
@onready var confirm_yes: Button = $ConfirmDialog/VBox/ButtonRow/ConfirmYes
@onready var confirm_no: Button = $ConfirmDialog/VBox/ButtonRow/ConfirmNo

func _ready() -> void:
	# Load save data (null-safe)
	if _has_save():
		Save.load_save()
	
	# Populate shift selector based on unlocked shifts
	_update_shift_dropdown()
	_update_progress_label()
	
	# Wire main buttons
	start_button.pressed.connect(_on_start)
	settings_button.pressed.connect(_open_settings)
	quit_button.pressed.connect(_on_quit)
	reset_button.pressed.connect(_on_reset_pressed)
	
	# Wire settings popup
	save_settings_btn.pressed.connect(_save_settings)
	close_settings_btn.pressed.connect(_close_settings)
	
	# Wire confirm dialog
	confirm_yes.pressed.connect(_confirm_reset)
	confirm_no.pressed.connect(_cancel_reset)
	
	# Apply settings to this scene
	if _has_save():
		Save.apply_settings_to_scene(self)

## Check if Save autoload exists (null-safe)
func _has_save() -> bool:
	return Engine.has_singleton("Save") or has_node("/root/Save")

## Update shift dropdown based on unlocked shifts
func _update_shift_dropdown() -> void:
	shift_select.clear()
	var max_shift = 1
	if _has_save():
		max_shift = Save.unlocked_max_shift
	
	for i in range(1, max_shift + 1):
		shift_select.add_item("Shift %02d" % i, i)
	
	shift_select.selected = shift_select.item_count - 1  # Select highest unlocked

## Update progress label
func _update_progress_label() -> void:
	var max_shift = 1
	if _has_save():
		max_shift = Save.unlocked_max_shift
	
	if max_shift >= 10:
		progress_label.text = "📊 All Shifts Unlocked! 🎉"
	else:
		progress_label.text = "📊 Unlocked: Shift 01 → Shift %02d" % max_shift

## Open settings popup
func _open_settings() -> void:
	if _has_save():
		sfx_check.button_pressed = Save.sfx_enabled
		events_check.button_pressed = Save.events_enabled
		motion_check.button_pressed = Save.reduce_motion
		vfx_slider.value = Save.vfx_intensity
	settings_popup.visible = true

## Save settings and close
func _save_settings() -> void:
	if _has_save():
		Save.sfx_enabled = sfx_check.button_pressed
		Save.events_enabled = events_check.button_pressed
		Save.reduce_motion = motion_check.button_pressed
		Save.vfx_intensity = vfx_slider.value
		Save.write_save()
		Save.apply_settings_to_scene(self)
	settings_popup.visible = false

## Close settings without saving
func _close_settings() -> void:
	settings_popup.visible = false

## Reset button pressed - show confirmation
func _on_reset_pressed() -> void:
	confirm_dialog.visible = true

## Confirm reset
func _confirm_reset() -> void:
	if _has_save():
		Save.reset_progress()
	confirm_dialog.visible = false
	_update_shift_dropdown()
	_update_progress_label()

## Cancel reset
func _cancel_reset() -> void:
	confirm_dialog.visible = false

func _on_start() -> void:
	var shift_num = shift_select.get_selected_id()
	if shift_num == 0:
		shift_num = 1
	# Store selected shift in autoload for Shift scene to read
	GameState.selected_shift = shift_num
	get_tree().change_scene_to_file("res://scenes/Shift.tscn")

func _on_quit() -> void:
	get_tree().quit()

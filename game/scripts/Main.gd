extends Control
## Main Menu with Shift Selector, Settings, and Progression
## Defensive: null-checks for Save autoload, graceful fallback

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
	var save_node = _get_save()
	if save_node:
		save_node.load_save()
	
	# Populate shift selector based on unlocked shifts
	_update_shift_dropdown()
	_update_progress_label()
	_init_settings_ui()
	
	# Wire main buttons (null-safe)
	if start_button:
		start_button.pressed.connect(_on_start)
	if settings_button:
		settings_button.pressed.connect(_open_settings)
	if quit_button:
		quit_button.pressed.connect(_on_quit)
	if reset_button:
		reset_button.pressed.connect(_on_reset_pressed)
	
	# Wire settings popup (null-safe)
	if save_settings_btn:
		save_settings_btn.pressed.connect(_save_settings)
	if close_settings_btn:
		close_settings_btn.pressed.connect(_close_settings)
	
	# Wire confirm dialog (null-safe)
	if confirm_yes:
		confirm_yes.pressed.connect(_confirm_reset)
	if confirm_no:
		confirm_no.pressed.connect(_cancel_reset)
	
	# Apply settings to this scene
	if save_node:
		save_node.apply_settings_to_scene(self)

## Get Save autoload node (null-safe, multiple methods)
func _get_save() -> Node:
	# Try direct path first
	var save_node = get_node_or_null("/root/Save")
	if save_node:
		return save_node
	
	# Try Engine singleton (Godot 4 method)
	if Engine.has_singleton("Save"):
		return Engine.get_singleton("Save")
	
	return null

## Check if Save autoload exists
func _has_save() -> bool:
	return _get_save() != null

## Update shift dropdown based on unlocked shifts
func _update_shift_dropdown() -> void:
	if not shift_select:
		return
	
	shift_select.clear()
	var max_shift = 1
	var save_node = _get_save()
	if save_node and "unlocked_max_shift" in save_node:
		max_shift = clampi(int(save_node.unlocked_max_shift), 1, 10)
	
	for i in range(1, max_shift + 1):
		shift_select.add_item("Shift %02d" % i, i)
	
	# Select highest unlocked by default
	if shift_select.item_count > 0:
		shift_select.selected = shift_select.item_count - 1

## Update progress label
func _update_progress_label() -> void:
	if not progress_label:
		return
	
	var max_shift = 1
	var save_node = _get_save()
	if save_node and "unlocked_max_shift" in save_node:
		max_shift = clampi(int(save_node.unlocked_max_shift), 1, 10)
	
	if max_shift >= 10:
		progress_label.text = "📊 All Shifts Unlocked! 🎉"
	else:
		progress_label.text = "📊 Unlocked: Shift 01 → Shift %02d" % max_shift

## Initialize settings UI from save values
func _init_settings_ui() -> void:
	var save_node = _get_save()
	if not save_node:
		return
	
	if sfx_check and "sfx_enabled" in save_node:
		sfx_check.button_pressed = bool(save_node.sfx_enabled)
	if events_check and "events_enabled" in save_node:
		events_check.button_pressed = bool(save_node.events_enabled)
	if motion_check and "reduce_motion" in save_node:
		motion_check.button_pressed = bool(save_node.reduce_motion)
	if vfx_slider and "vfx_intensity" in save_node:
		vfx_slider.value = float(save_node.vfx_intensity)

## Open settings popup
func _open_settings() -> void:
	_init_settings_ui()
	if settings_popup:
		settings_popup.visible = true

## Save settings and close
func _save_settings() -> void:
	var save_node = _get_save()
	if save_node:
		if sfx_check and "sfx_enabled" in save_node:
			save_node.sfx_enabled = sfx_check.button_pressed
		if events_check and "events_enabled" in save_node:
			save_node.events_enabled = events_check.button_pressed
		if motion_check and "reduce_motion" in save_node:
			save_node.reduce_motion = motion_check.button_pressed
		if vfx_slider and "vfx_intensity" in save_node:
			save_node.vfx_intensity = vfx_slider.value
		
		if save_node.has_method("write_save"):
			save_node.write_save()
		if save_node.has_method("apply_settings_to_scene"):
			save_node.apply_settings_to_scene(self)
	
	if settings_popup:
		settings_popup.visible = false
	
	_update_progress_label()
	_update_shift_dropdown()

## Close settings without saving
func _close_settings() -> void:
	if settings_popup:
		settings_popup.visible = false

## Reset button pressed - show confirmation
func _on_reset_pressed() -> void:
	if confirm_dialog:
		confirm_dialog.visible = true

## Confirm reset
func _confirm_reset() -> void:
	var save_node = _get_save()
	if save_node:
		if save_node.has_method("reset_progress"):
			save_node.reset_progress()
		if save_node.has_method("write_save"):
			save_node.write_save()
	
	if confirm_dialog:
		confirm_dialog.visible = false
	
	_update_shift_dropdown()
	_update_progress_label()

## Cancel reset
func _cancel_reset() -> void:
	if confirm_dialog:
		confirm_dialog.visible = false

func _on_start() -> void:
	if not shift_select:
		return
	
	var shift_num = shift_select.get_selected_id()
	if shift_num == 0:
		shift_num = 1
	
	# Store selected shift in autoload for Shift scene to read
	var gamestate = get_node_or_null("/root/GameState")
	if gamestate and "selected_shift" in gamestate:
		gamestate.selected_shift = shift_num
	
	get_tree().change_scene_to_file("res://scenes/Shift.tscn")

func _on_quit() -> void:
	get_tree().quit()

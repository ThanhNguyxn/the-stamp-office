extends Control
## Settings Menu - Audio, Graphics, Gameplay options

signal settings_closed

# Audio
@onready var master_slider: HSlider = $Panel/VBox/AudioSection/MasterVolume/Slider
@onready var sfx_slider: HSlider = $Panel/VBox/AudioSection/SFXVolume/Slider
@onready var music_slider: HSlider = $Panel/VBox/AudioSection/MusicVolume/Slider

# Graphics
@onready var display_mode_option: OptionButton = $Panel/VBox/GraphicsSection/DisplayMode/OptionButton
@onready var resolution_option: OptionButton = $Panel/VBox/GraphicsSection/Resolution/OptionButton
@onready var vsync_check: CheckButton = $Panel/VBox/GraphicsSection/VSync/CheckButton
@onready var quality_option: OptionButton = $Panel/VBox/GraphicsSection/Quality/OptionButton

# Gameplay
@onready var sensitivity_slider: HSlider = $Panel/VBox/GameplaySection/Sensitivity/Slider
@onready var jumpscare_check: CheckButton = $Panel/VBox/GameplaySection/Jumpscares/CheckButton
@onready var screenshake_check: CheckButton = $Panel/VBox/GameplaySection/ScreenShake/CheckButton

# Default values
var settings_data := {
	"master_volume": 0.8,
	"sfx_volume": 0.8,
	"music_volume": 0.6,
	"display_mode": 0,  # 0=Fullscreen, 1=Borderless, 2=Windowed, 3=Windowed Resizable
	"resolution": 2,    # 0=720p, 1=900p, 2=1080p, 3=1440p, 4=4K
	"vsync": true,
	"quality": 2,  # 0=Low, 1=Medium, 2=High
	"mouse_sensitivity": 0.5,
	"jumpscares_enabled": true,
	"screenshake_enabled": true
}

const RESOLUTIONS := [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160)
]

const SETTINGS_PATH := "user://settings.cfg"

func _ready() -> void:
	load_settings()
	apply_settings()
	_connect_signals()
	hide()

func _connect_signals() -> void:
	if master_slider:
		master_slider.value_changed.connect(_on_master_changed)
	if sfx_slider:
		sfx_slider.value_changed.connect(_on_sfx_changed)
	if music_slider:
		music_slider.value_changed.connect(_on_music_changed)
	if display_mode_option:
		display_mode_option.item_selected.connect(_on_display_mode_selected)
	if resolution_option:
		resolution_option.item_selected.connect(_on_resolution_selected)
	if vsync_check:
		vsync_check.toggled.connect(_on_vsync_toggled)
	if quality_option:
		quality_option.item_selected.connect(_on_quality_selected)
	if sensitivity_slider:
		sensitivity_slider.value_changed.connect(_on_sensitivity_changed)
	if jumpscare_check:
		jumpscare_check.toggled.connect(_on_jumpscare_toggled)
	if screenshake_check:
		screenshake_check.toggled.connect(_on_screenshake_toggled)

func _on_master_changed(value: float) -> void:
	settings_data["master_volume"] = value
	_apply_audio()

func _on_sfx_changed(value: float) -> void:
	settings_data["sfx_volume"] = value
	_apply_audio()

func _on_music_changed(value: float) -> void:
	settings_data["music_volume"] = value
	_apply_audio()

func _on_display_mode_selected(index: int) -> void:
	settings_data["display_mode"] = index
	_apply_display()

func _on_resolution_selected(index: int) -> void:
	settings_data["resolution"] = index
	_apply_display()

func _on_vsync_toggled(enabled: bool) -> void:
	settings_data["vsync"] = enabled
	_apply_display()

func _on_quality_selected(index: int) -> void:
	settings_data["quality"] = index
	_apply_graphics()

func _on_sensitivity_changed(value: float) -> void:
	settings_data["mouse_sensitivity"] = value

func _on_jumpscare_toggled(enabled: bool) -> void:
	settings_data["jumpscares_enabled"] = enabled

func _on_screenshake_toggled(enabled: bool) -> void:
	settings_data["screenshake_enabled"] = enabled

func _apply_audio() -> void:
	var master_db = linear_to_db(settings_data["master_volume"])
	var sfx_db = linear_to_db(settings_data["sfx_volume"])
	var music_db = linear_to_db(settings_data["music_volume"])
	
	if AudioServer.get_bus_index("Master") >= 0:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), master_db)
	if AudioServer.get_bus_index("SFX") >= 0:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), sfx_db)
	if AudioServer.get_bus_index("Music") >= 0:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), music_db)

func _apply_display() -> void:
	var mode = settings_data["display_mode"]
	var res_idx = settings_data["resolution"]
	var resolution = RESOLUTIONS[res_idx] if res_idx < RESOLUTIONS.size() else RESOLUTIONS[2]
	
	match mode:
		0:  # Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		1:  # Borderless
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			DisplayServer.window_set_size(resolution)
			_center_window()
		2:  # Windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, true)
			DisplayServer.window_set_size(resolution)
			_center_window()
		3:  # Windowed Resizable
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, false)
			DisplayServer.window_set_size(resolution)
			_center_window()
	
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if settings_data["vsync"] else DisplayServer.VSYNC_DISABLED
	)

func _center_window() -> void:
	var screen_size = DisplayServer.screen_get_size()
	var window_size = DisplayServer.window_get_size()
	var pos = (screen_size - window_size) / 2
	DisplayServer.window_set_position(pos)

func _apply_graphics() -> void:
	var quality = settings_data["quality"]
	var vp = get_viewport()
	if not vp:
		return
	
	match quality:
		0:  # Low
			vp.msaa_3d = Viewport.MSAA_DISABLED
			RenderingServer.directional_shadow_atlas_set_size(1024, true)
		1:  # Medium
			vp.msaa_3d = Viewport.MSAA_2X
			RenderingServer.directional_shadow_atlas_set_size(2048, true)
		2:  # High
			vp.msaa_3d = Viewport.MSAA_4X
			RenderingServer.directional_shadow_atlas_set_size(4096, true)

func apply_settings() -> void:
	_apply_audio()
	_apply_display()
	_apply_graphics()
	_update_ui()

func _update_ui() -> void:
	if master_slider:
		master_slider.value = settings_data["master_volume"]
	if sfx_slider:
		sfx_slider.value = settings_data["sfx_volume"]
	if music_slider:
		music_slider.value = settings_data["music_volume"]
	if display_mode_option:
		display_mode_option.selected = settings_data["display_mode"]
	if resolution_option:
		resolution_option.selected = settings_data["resolution"]
	if vsync_check:
		vsync_check.button_pressed = settings_data["vsync"]
	if quality_option:
		quality_option.selected = settings_data["quality"]
	if sensitivity_slider:
		sensitivity_slider.value = settings_data["mouse_sensitivity"]
	if jumpscare_check:
		jumpscare_check.button_pressed = settings_data["jumpscares_enabled"]
	if screenshake_check:
		screenshake_check.button_pressed = settings_data["screenshake_enabled"]

func save_settings() -> void:
	var config = ConfigFile.new()
	for key in settings_data:
		config.set_value("settings", key, settings_data[key])
	config.save(SETTINGS_PATH)
	print("[Settings] Saved to ", SETTINGS_PATH)

func load_settings() -> void:
	var config = ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		for key in settings_data:
			if config.has_section_key("settings", key):
				settings_data[key] = config.get_value("settings", key)
		print("[Settings] Loaded from ", SETTINGS_PATH)

func open_settings() -> void:
	_update_ui()
	show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func close_settings() -> void:
	save_settings()
	hide()
	settings_closed.emit()

func _on_back_pressed() -> void:
	close_settings()

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close_settings()
		get_viewport().set_input_as_handled()

# Getters for other scripts
func get_sensitivity() -> float:
	return settings_data["mouse_sensitivity"]

func are_jumpscares_enabled() -> bool:
	return settings_data["jumpscares_enabled"]

func is_screenshake_enabled() -> bool:
	return settings_data["screenshake_enabled"]

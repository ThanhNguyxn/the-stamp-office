extends Node
## Save - Persistent save and settings system
## Stores progression and user preferences in user://save.json

const SAVE_PATH = "user://save.json"

# Progression
var unlocked_max_shift: int = 1

# Settings
var sfx_enabled: bool = true
var vfx_intensity: float = 1.0
var events_enabled: bool = true
var reduce_motion: bool = false

func _ready() -> void:
	load_save()

## Load save data from file
func load_save() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		# No save file, use defaults
		return
	
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	file.close()
	
	if error != OK:
		push_warning("Save: Failed to parse save file")
		return
	
	var data = json.get_data()
	if not data is Dictionary:
		return
	
	# Load progression
	unlocked_max_shift = int(data.get("unlocked_max_shift", 1))
	unlocked_max_shift = clampi(unlocked_max_shift, 1, 10)
	
	# Load settings
	var settings = data.get("settings", {})
	if settings is Dictionary:
		sfx_enabled = bool(settings.get("sfx_enabled", true))
		vfx_intensity = clampf(float(settings.get("vfx_intensity", 1.0)), 0.0, 1.0)
		events_enabled = bool(settings.get("events_enabled", true))
		reduce_motion = bool(settings.get("reduce_motion", false))

## Write save data to file
func write_save() -> void:
	var data = {
		"unlocked_max_shift": unlocked_max_shift,
		"settings": {
			"sfx_enabled": sfx_enabled,
			"vfx_intensity": vfx_intensity,
			"events_enabled": events_enabled,
			"reduce_motion": reduce_motion
		}
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		push_error("Save: Failed to open save file for writing")
		return
	
	file.store_string(JSON.stringify(data, "\t"))
	file.close()

## Unlock a shift (call when completing a shift)
func unlock_shift(shift_number: int) -> void:
	if shift_number > unlocked_max_shift and shift_number <= 10:
		unlocked_max_shift = shift_number
		write_save()

## Check if a shift is unlocked
func is_shift_unlocked(shift_number: int) -> bool:
	return shift_number >= 1 and shift_number <= unlocked_max_shift

## Reset progression to beginning
func reset_progress() -> void:
	unlocked_max_shift = 1
	write_save()

## Apply settings to a scene (find Sfx and ShiftEvents nodes)
func apply_settings_to_scene(root: Node) -> void:
	if not root:
		return
	
	# Find and configure Sfx node
	var sfx_node = root.find_child("Sfx", true, false)
	if sfx_node and sfx_node.has_method("set_enabled"):
		sfx_node.set_enabled(sfx_enabled)
	
	# Find and configure ShiftEvents node
	var events_node = root.find_child("ShiftEvents", true, false)
	if events_node:
		# Stop events if disabled
		if not events_enabled and events_node.has_method("stop"):
			events_node.stop()
	
	# Find and configure scanline overlay
	var scanline = root.find_child("ScanlineOverlay", true, false)
	if scanline and scanline.material:
		var mat = scanline.material as ShaderMaterial
		if mat:
			mat.set_shader_parameter("scanline_intensity", 0.08 * vfx_intensity)
			mat.set_shader_parameter("vignette_intensity", 0.15 * vfx_intensity)

## Get current settings as dictionary (for UI)
func get_settings() -> Dictionary:
	return {
		"sfx_enabled": sfx_enabled,
		"vfx_intensity": vfx_intensity,
		"events_enabled": events_enabled,
		"reduce_motion": reduce_motion
	}

## Update settings from dictionary (from UI)
func set_settings(settings: Dictionary) -> void:
	sfx_enabled = bool(settings.get("sfx_enabled", sfx_enabled))
	vfx_intensity = clampf(float(settings.get("vfx_intensity", vfx_intensity)), 0.0, 1.0)
	events_enabled = bool(settings.get("events_enabled", events_enabled))
	reduce_motion = bool(settings.get("reduce_motion", reduce_motion))
	write_save()

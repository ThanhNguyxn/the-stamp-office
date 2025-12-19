extends Node
## Save - Persistent save and settings system
## Stores progression and user preferences in user://save.json
## Defensive: null-checks everywhere, fallback to defaults if corrupt

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
	if not FileAccess.file_exists(SAVE_PATH):
		# No save file - write defaults
		write_save()
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		# Can't open - use defaults and try to write
		push_warning("Save: Cannot open save file, using defaults")
		write_save()
		return
	
	var content = file.get_as_text()
	file.close()
	
	if content.is_empty():
		# Empty file - write defaults
		write_save()
		return
	
	var json = JSON.new()
	var error = json.parse(content)
	
	if error != OK:
		# Corrupt file - write defaults
		push_warning("Save: Corrupt save file, resetting to defaults")
		write_save()
		return
	
	var data = json.get_data()
	if not data is Dictionary:
		# Invalid structure - write defaults
		write_save()
		return
	
	# Load progression with validation
	var raw_shift = data.get("unlocked_max_shift", 1)
	if raw_shift is int or raw_shift is float:
		unlocked_max_shift = clampi(int(raw_shift), 1, 10)
	else:
		unlocked_max_shift = 1
	
	# Load settings with validation
	var settings = data.get("settings", {})
	if settings is Dictionary:
		# sfx_enabled
		var raw_sfx = settings.get("sfx_enabled", true)
		sfx_enabled = bool(raw_sfx) if raw_sfx != null else true
		
		# vfx_intensity (clamp 0..1)
		var raw_vfx = settings.get("vfx_intensity", 1.0)
		if raw_vfx is int or raw_vfx is float:
			vfx_intensity = clampf(float(raw_vfx), 0.0, 1.0)
		else:
			vfx_intensity = 1.0
		
		# events_enabled
		var raw_events = settings.get("events_enabled", true)
		events_enabled = bool(raw_events) if raw_events != null else true
		
		# reduce_motion
		var raw_motion = settings.get("reduce_motion", false)
		reduce_motion = bool(raw_motion) if raw_motion != null else false

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
		# Note: caller should call write_save()

## Check if a shift is unlocked
func is_shift_unlocked(shift_number: int) -> bool:
	return shift_number >= 1 and shift_number <= unlocked_max_shift

## Reset progression to beginning
func reset_progress() -> void:
	unlocked_max_shift = 1
	# Note: caller should call write_save()

## Apply settings to a scene (recursive search, null-safe)
func apply_settings_to_scene(root: Node) -> void:
	if not root:
		return
	
	# === SFX node(s) ===
	_apply_sfx_settings(root)
	
	# === ShiftEvents node(s) ===
	_apply_events_settings(root)
	
	# === Visual effects (scanline overlay, etc.) ===
	_apply_vfx_settings(root)

## Helper: Apply SFX settings recursively
func _apply_sfx_settings(root: Node) -> void:
	var sfx_node = _find_node_safe(root, "Sfx")
	if sfx_node:
		# Try set_enabled method
		if sfx_node.has_method("set_enabled"):
			sfx_node.set_enabled(sfx_enabled)
		# Try enabled property
		elif "enabled" in sfx_node:
			sfx_node.set("enabled", sfx_enabled)
		# Try volume_db (mute by setting very low)
		elif "volume_db" in sfx_node:
			sfx_node.set("volume_db", 0.0 if sfx_enabled else -80.0)

## Helper: Apply events settings recursively
func _apply_events_settings(root: Node) -> void:
	var events_node = _find_node_safe(root, "ShiftEvents")
	if events_node:
		# Try events_enabled property
		if "events_enabled" in events_node:
			events_node.set("events_enabled", events_enabled)
		# Try enabled property
		elif "enabled" in events_node:
			events_node.set("enabled", events_enabled)
		# Try stopping if disabled
		if not events_enabled and events_node.has_method("stop"):
			events_node.stop()

## Helper: Apply VFX settings recursively
func _apply_vfx_settings(root: Node) -> void:
	# Scanline overlay
	var scanline = _find_node_safe(root, "ScanlineOverlay")
	if scanline:
		_apply_shader_intensity(scanline, vfx_intensity)
	
	# Look for any other VFX nodes by common names
	for name in ["VfxOverlay", "Vignette", "PostProcess", "Effects"]:
		var node = _find_node_safe(root, name)
		if node:
			_apply_shader_intensity(node, vfx_intensity)
			# Try intensity property
			if "intensity" in node:
				node.set("intensity", node.get("intensity") * vfx_intensity)
			if "strength" in node:
				node.set("strength", node.get("strength") * vfx_intensity)

## Helper: Apply intensity to shader material
func _apply_shader_intensity(node: Node, intensity: float) -> void:
	if not node:
		return
	
	# Check if it has a material property
	if not "material" in node:
		return
	
	var mat = node.get("material")
	if not mat or not mat is ShaderMaterial:
		return
	
	var shader_mat = mat as ShaderMaterial
	
	# Common intensity parameter names
	for param in ["scanline_intensity", "vignette_intensity", "intensity", "strength"]:
		var current = shader_mat.get_shader_parameter(param)
		if current != null and (current is float or current is int):
			# Scale relative to base values
			var base_values = {
				"scanline_intensity": 0.08,
				"vignette_intensity": 0.15,
				"intensity": 1.0,
				"strength": 1.0
			}
			var base = base_values.get(param, 1.0)
			shader_mat.set_shader_parameter(param, base * intensity)

## Helper: Find node by name (recursive, null-safe)
func _find_node_safe(root: Node, node_name: String) -> Node:
	if not root:
		return null
	return root.find_child(node_name, true, false)

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
	if settings.has("sfx_enabled"):
		sfx_enabled = bool(settings.get("sfx_enabled"))
	if settings.has("vfx_intensity"):
		vfx_intensity = clampf(float(settings.get("vfx_intensity")), 0.0, 1.0)
	if settings.has("events_enabled"):
		events_enabled = bool(settings.get("events_enabled"))
	if settings.has("reduce_motion"):
		reduce_motion = bool(settings.get("reduce_motion"))

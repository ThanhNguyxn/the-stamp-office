extends Node
## Save - Persistent save and settings system
## Stores progression, settings, and story flags in user://save.json
## Backwards-compatible: new fields have defaults

const SAVE_PATH = "user://save.json"

# Progression
var unlocked_max_shift: int = 1

# Settings
var sfx_enabled: bool = true
var vfx_intensity: float = 1.0
var events_enabled: bool = true
var reduce_motion: bool = false
var jumpscares_enabled: bool = true
var screenshake_enabled: bool = true

# Story flags (for endings)
var denied_level7_count: int = 0
var secret_stamp_unlocked: bool = false
var secret_stamp_targets: Dictionary = {}  # ticket_text -> true
var last_ending: String = ""
var total_mood: int = 0
var total_contradiction: int = 0

func _ready() -> void:
	load_save()

## Load save data from file
func load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		write_save()
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		push_warning("Save: Cannot open save file, using defaults")
		write_save()
		return
	
	var content = file.get_as_text()
	file.close()
	
	if content.is_empty():
		write_save()
		return
	
	var json = JSON.new()
	var error = json.parse(content)
	
	if error != OK:
		push_warning("Save: Corrupt save file, resetting to defaults")
		write_save()
		return
	
	var data = json.get_data()
	if not data is Dictionary:
		write_save()
		return
	
	# Load progression
	var raw_shift = data.get("unlocked_max_shift", 1)
	if raw_shift is int or raw_shift is float:
		unlocked_max_shift = clampi(int(raw_shift), 1, 10)
	else:
		unlocked_max_shift = 1
	
	# Load settings
	var settings = data.get("settings", {})
	if settings is Dictionary:
		var raw_sfx = settings.get("sfx_enabled", true)
		sfx_enabled = bool(raw_sfx) if raw_sfx != null else true
		
		var raw_vfx = settings.get("vfx_intensity", 1.0)
		if raw_vfx is int or raw_vfx is float:
			vfx_intensity = clampf(float(raw_vfx), 0.0, 1.0)
		else:
			vfx_intensity = 1.0
		
		var raw_events = settings.get("events_enabled", true)
		events_enabled = bool(raw_events) if raw_events != null else true
		
		var raw_motion = settings.get("reduce_motion", false)
		reduce_motion = bool(raw_motion) if raw_motion != null else false
		
		var raw_jumpscares = settings.get("jumpscares_enabled", true)
		jumpscares_enabled = bool(raw_jumpscares) if raw_jumpscares != null else true
		
		var raw_screenshake = settings.get("screenshake_enabled", true)
		screenshake_enabled = bool(raw_screenshake) if raw_screenshake != null else true
	
	# Load story flags (backwards-compatible)
	var story = data.get("story", {})
	if story is Dictionary:
		var raw_denied = story.get("denied_level7_count", 0)
		if raw_denied is int or raw_denied is float:
			denied_level7_count = maxi(int(raw_denied), 0)
		
		secret_stamp_unlocked = bool(story.get("secret_stamp_unlocked", false))
		
		var raw_targets = story.get("secret_stamp_targets", {})
		if raw_targets is Dictionary:
			secret_stamp_targets = raw_targets
		else:
			secret_stamp_targets = {}
		
		last_ending = str(story.get("last_ending", ""))
		
		var raw_mood = story.get("total_mood", 0)
		if raw_mood is int or raw_mood is float:
			total_mood = int(raw_mood)
		
		var raw_contra = story.get("total_contradiction", 0)
		if raw_contra is int or raw_contra is float:
			total_contradiction = int(raw_contra)

## Write save data to file
func write_save() -> void:
	var data = {
		"unlocked_max_shift": unlocked_max_shift,
		"settings": {
			"sfx_enabled": sfx_enabled,
			"vfx_intensity": vfx_intensity,
			"events_enabled": events_enabled,
			"reduce_motion": reduce_motion,
			"jumpscares_enabled": jumpscares_enabled,
			"screenshake_enabled": screenshake_enabled
		},
		"story": {
			"denied_level7_count": denied_level7_count,
			"secret_stamp_unlocked": secret_stamp_unlocked,
			"secret_stamp_targets": secret_stamp_targets,
			"last_ending": last_ending,
			"total_mood": total_mood,
			"total_contradiction": total_contradiction
		}
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		push_error("Save: Failed to open save file for writing")
		return
	
	file.store_string(JSON.stringify(data, "\t"))
	file.close()

## Unlock a shift
func unlock_shift(shift_number: int) -> void:
	if shift_number > unlocked_max_shift and shift_number <= 10:
		unlocked_max_shift = shift_number

## Check if a shift is unlocked
func is_shift_unlocked(shift_number: int) -> bool:
	return shift_number >= 1 and shift_number <= unlocked_max_shift

## Reset progression (but keep settings)
func reset_progress() -> void:
	unlocked_max_shift = 1
	denied_level7_count = 0
	secret_stamp_unlocked = false
	secret_stamp_targets = {}
	last_ending = ""
	total_mood = 0
	total_contradiction = 0

## Track Level 7 deny
func track_level7_deny() -> void:
	denied_level7_count += 1
	write_save()

## Unlock secret stamp (called in Shift 08)
func unlock_secret_stamp() -> void:
	secret_stamp_unlocked = true
	write_save()

## Track secret stamp usage on target ticket
func track_secret_stamp_use(ticket_text: String) -> void:
	# Check if this is a target ticket
	var targets = [
		"Requesting proof The Office exists.",
		"Requesting acknowledgment of the void.",
		"Requesting exit. Any exit."
	]
	for target in targets:
		if ticket_text.contains(target) or target in ticket_text:
			secret_stamp_targets[target] = true
			write_save()
			return

## Check if all 3 secret targets have been stamped
func has_all_secret_targets() -> bool:
	var targets = [
		"Requesting proof The Office exists.",
		"Requesting acknowledgment of the void.",
		"Requesting exit. Any exit."
	]
	for target in targets:
		if not secret_stamp_targets.has(target):
			return false
	return true

## Get secret target count
func get_secret_target_count() -> int:
	return secret_stamp_targets.size()

## Update totals from a completed shift
func update_totals(mood: int, contradiction: int) -> void:
	total_mood += mood
	total_contradiction += contradiction
	write_save()

## Set last ending
func set_ending(ending_name: String) -> void:
	last_ending = ending_name
	write_save()

## Apply settings to a scene
func apply_settings_to_scene(root: Node) -> void:
	if not root:
		return
	_apply_sfx_settings(root)
	_apply_events_settings(root)
	_apply_vfx_settings(root)

func _apply_sfx_settings(root: Node) -> void:
	var sfx_node = _find_node_safe(root, "Sfx")
	if sfx_node:
		if sfx_node.has_method("set_enabled"):
			sfx_node.set_enabled(sfx_enabled)
		elif "enabled" in sfx_node:
			sfx_node.set("enabled", sfx_enabled)
		elif "volume_db" in sfx_node:
			sfx_node.set("volume_db", 0.0 if sfx_enabled else -80.0)

func _apply_events_settings(root: Node) -> void:
	var events_node = _find_node_safe(root, "ShiftEvents")
	if events_node:
		if "events_enabled" in events_node:
			events_node.set("events_enabled", events_enabled)
		elif "enabled" in events_node:
			events_node.set("enabled", events_enabled)
		if not events_enabled and events_node.has_method("stop"):
			events_node.stop()

func _apply_vfx_settings(root: Node) -> void:
	var scanline = _find_node_safe(root, "ScanlineOverlay")
	if scanline:
		_apply_shader_intensity(scanline, vfx_intensity)
	for name in ["VfxOverlay", "Vignette", "PostProcess", "Effects"]:
		var node = _find_node_safe(root, name)
		if node:
			_apply_shader_intensity(node, vfx_intensity)
			if "intensity" in node:
				node.set("intensity", node.get("intensity") * vfx_intensity)
			if "strength" in node:
				node.set("strength", node.get("strength") * vfx_intensity)

func _apply_shader_intensity(node: Node, intensity: float) -> void:
	if not node or not "material" in node:
		return
	var mat = node.get("material")
	if not mat or not mat is ShaderMaterial:
		return
	var shader_mat = mat as ShaderMaterial
	for param in ["scanline_intensity", "vignette_intensity", "intensity", "strength"]:
		var current = shader_mat.get_shader_parameter(param)
		if current != null and (current is float or current is int):
			var base_values = {
				"scanline_intensity": 0.08,
				"vignette_intensity": 0.15,
				"intensity": 1.0,
				"strength": 1.0
			}
			var base = base_values.get(param, 1.0)
			shader_mat.set_shader_parameter(param, base * intensity)

func _find_node_safe(root: Node, node_name: String) -> Node:
	if not root:
		return null
	return root.find_child(node_name, true, false)

func get_settings() -> Dictionary:
	return {
		"sfx_enabled": sfx_enabled,
		"vfx_intensity": vfx_intensity,
		"events_enabled": events_enabled,
		"reduce_motion": reduce_motion
	}

func set_settings(settings: Dictionary) -> void:
	if settings.has("sfx_enabled"):
		sfx_enabled = bool(settings.get("sfx_enabled"))
	if settings.has("vfx_intensity"):
		vfx_intensity = clampf(float(settings.get("vfx_intensity")), 0.0, 1.0)
	if settings.has("events_enabled"):
		events_enabled = bool(settings.get("events_enabled"))
	if settings.has("reduce_motion"):
		reduce_motion = bool(settings.get("reduce_motion"))

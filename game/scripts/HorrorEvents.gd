extends Node
## HorrorEvents - Manages jumpscares, glitches, and atmospheric horror
## Subtle scares that build tension without cheap jump scares

signal horror_event_triggered(event_type: String)

# Event types
enum EventType {
	LIGHT_FLICKER,
	SCREEN_GLITCH,
	WHISPER,
	OBJECT_MOVE,
	CLERK_STARE,
	SHADOW_PASS,
	STATIC_BURST,
	INTERCOM_VOICE
}

# Settings
var jumpscares_enabled := true
var screenshake_enabled := true

# State
var tension_level: float = 0.0  # 0.0 to 1.0, increases with wrong decisions
var current_shift: int = 1
var events_triggered: int = 0
var last_event_time: float = 0.0
var min_event_interval: float = 30.0  # Minimum seconds between events

# References (set by parent scene)
var camera: Camera3D = null
var environment: Environment = null
var office_lights: Array[Light3D] = []

# Audio players
var whisper_player: AudioStreamPlayer
var static_player: AudioStreamPlayer
var ambient_player: AudioStreamPlayer

# Preload horror sounds (placeholders - you'd add actual .ogg/.wav files)
var horror_sounds := {
	"whisper": null,
	"static": null,
	"creak": null,
	"breath": null,
	"intercom": null
}

func _ready() -> void:
	_setup_audio_players()
	_load_settings()
	set_process(true)

func _load_settings() -> void:
	var save_node = get_node_or_null("/root/Save")
	if save_node:
		if "jumpscares_enabled" in save_node:
			jumpscares_enabled = bool(save_node.jumpscares_enabled)
		if "screenshake_enabled" in save_node:
			screenshake_enabled = bool(save_node.screenshake_enabled)
	print("[Horror] Settings loaded - Jumpscares: %s, Screenshake: %s" % [jumpscares_enabled, screenshake_enabled])

func _setup_audio_players() -> void:
	whisper_player = AudioStreamPlayer.new()
	whisper_player.bus = "SFX"
	whisper_player.volume_db = -10
	add_child(whisper_player)
	
	static_player = AudioStreamPlayer.new()
	static_player.bus = "SFX"
	static_player.volume_db = -15
	add_child(static_player)
	
	ambient_player = AudioStreamPlayer.new()
	ambient_player.bus = "Music"
	ambient_player.volume_db = -20
	add_child(ambient_player)

func _process(delta: float) -> void:
	if not jumpscares_enabled:
		return
	
	last_event_time += delta
	
	# Random chance of horror event based on tension
	if last_event_time >= min_event_interval:
		var event_chance = tension_level * 0.001 * delta  # Very rare
		if randf() < event_chance:
			trigger_random_event()

func set_tension(level: float) -> void:
	tension_level = clampf(level, 0.0, 1.0)
	# Higher tension = more frequent events
	min_event_interval = lerpf(60.0, 15.0, tension_level)

func increase_tension(amount: float = 0.1) -> void:
	set_tension(tension_level + amount)
	print("[Horror] Tension: %.1f%%" % (tension_level * 100))

func set_shift(shift: int) -> void:
	current_shift = shift
	# Later shifts = more intense events
	if shift >= 6:
		min_event_interval *= 0.7  # Events happen more often

func trigger_random_event() -> void:
	if not jumpscares_enabled:
		return
	
	var available_events: Array[EventType] = []
	
	# Early shifts: only subtle events
	if current_shift <= 3:
		available_events = [EventType.LIGHT_FLICKER, EventType.WHISPER]
	elif current_shift <= 6:
		available_events = [
			EventType.LIGHT_FLICKER, 
			EventType.WHISPER,
			EventType.SCREEN_GLITCH,
			EventType.OBJECT_MOVE
		]
	else:
		# Late game: all events
		available_events = [
			EventType.LIGHT_FLICKER,
			EventType.SCREEN_GLITCH,
			EventType.WHISPER,
			EventType.CLERK_STARE,
			EventType.SHADOW_PASS,
			EventType.STATIC_BURST,
			EventType.INTERCOM_VOICE
		]
	
	var event = available_events[randi() % available_events.size()]
	trigger_event(event)

func trigger_event(event: EventType) -> void:
	if not jumpscares_enabled:
		return
	
	last_event_time = 0.0
	events_triggered += 1
	
	match event:
		EventType.LIGHT_FLICKER:
			_do_light_flicker()
		EventType.SCREEN_GLITCH:
			_do_screen_glitch()
		EventType.WHISPER:
			_do_whisper()
		EventType.OBJECT_MOVE:
			_do_object_move()
		EventType.CLERK_STARE:
			_do_clerk_stare()
		EventType.SHADOW_PASS:
			_do_shadow_pass()
		EventType.STATIC_BURST:
			_do_static_burst()
		EventType.INTERCOM_VOICE:
			_do_intercom_voice()
	
	horror_event_triggered.emit(EventType.keys()[event])
	print("[Horror] Event: %s" % EventType.keys()[event])

func _do_light_flicker() -> void:
	if office_lights.is_empty():
		return
	
	var light = office_lights[randi() % office_lights.size()]
	var original_energy = light.light_energy
	
	var tween = create_tween()
	tween.tween_property(light, "light_energy", 0.1, 0.05)
	tween.tween_property(light, "light_energy", original_energy * 0.7, 0.03)
	tween.tween_property(light, "light_energy", 0.0, 0.02)
	tween.tween_property(light, "light_energy", original_energy * 0.5, 0.04)
	tween.tween_property(light, "light_energy", 0.2, 0.03)
	tween.tween_property(light, "light_energy", original_energy, 0.1)

func _do_screen_glitch() -> void:
	if not camera:
		return
	
	# Screen shake if enabled
	if screenshake_enabled:
		_screen_shake(0.3, 0.05)
	
	# Brief color aberration effect via environment
	if environment:
		var original_saturation = environment.adjustment_saturation
		var tween = create_tween()
		tween.tween_property(environment, "adjustment_saturation", 0.0, 0.05)
		tween.tween_property(environment, "adjustment_saturation", 1.5, 0.03)
		tween.tween_property(environment, "adjustment_saturation", original_saturation, 0.1)

func _do_whisper() -> void:
	# Play whisper sound
	if whisper_player and horror_sounds["whisper"]:
		whisper_player.stream = horror_sounds["whisper"]
		whisper_player.play()
	
	print("[Horror] *whisper*... did you hear that?")

func _do_object_move() -> void:
	# This would move a random prop slightly
	# For now just print
	print("[Horror] Something moved in the corner of your eye...")

func _do_clerk_stare() -> void:
	# Clerk turns to look at player
	print("[Horror] The clerk is staring at you...")
	# Would rotate clerk to face camera

func _do_shadow_pass() -> void:
	# Brief shadow crosses screen
	if screenshake_enabled:
		_screen_shake(0.1, 0.02)
	print("[Horror] A shadow passes by...")

func _do_static_burst() -> void:
	if static_player and horror_sounds["static"]:
		static_player.stream = horror_sounds["static"]
		static_player.play()
	
	# Brief static on screen
	if environment:
		var tween = create_tween()
		tween.tween_property(environment, "glow_intensity", 2.0, 0.02)
		tween.tween_property(environment, "glow_intensity", 0.2, 0.1)

func _do_intercom_voice() -> void:
	# Play distorted voice
	print("[Horror] *CRACKLE* ...remain... calm... *STATIC*")
	
	# This would display a toast message
	# GameState.show_toast("...remain calm...", "warning")

func _screen_shake(duration: float, intensity: float) -> void:
	if not camera or not screenshake_enabled:
		return
	
	var original_pos = camera.position
	var tween = create_tween()
	var shake_count = int(duration / 0.02)
	
	for i in shake_count:
		var offset = Vector3(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity),
			0
		)
		tween.tween_property(camera, "position", original_pos + offset, 0.02)
	
	tween.tween_property(camera, "position", original_pos, 0.05)

# Called when player makes wrong decision
func on_wrong_decision() -> void:
	increase_tension(0.15)
	
	# Small chance of immediate event
	if randf() < tension_level * 0.3:
		trigger_event(EventType.LIGHT_FLICKER)

# Called when mood meter is low
func on_mood_critical() -> void:
	increase_tension(0.25)
	
	if current_shift >= 5:
		trigger_event(EventType.WHISPER)

# Big scare for key story moments (use sparingly!)
func trigger_story_scare(intensity: String = "low") -> void:
	if not jumpscares_enabled:
		return
	
	match intensity:
		"low":
			trigger_event(EventType.LIGHT_FLICKER)
		"medium":
			trigger_event(EventType.SCREEN_GLITCH)
			await get_tree().create_timer(0.5).timeout
			trigger_event(EventType.WHISPER)
		"high":
			trigger_event(EventType.STATIC_BURST)
			await get_tree().create_timer(0.3).timeout
			trigger_event(EventType.SCREEN_GLITCH)
			if screenshake_enabled:
				_screen_shake(0.5, 0.1)

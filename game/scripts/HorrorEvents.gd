extends Node
## HorrorEvents - Manages jumpscares, glitches, and atmospheric horror
## Subtle scares that build tension without cheap jump scares

signal horror_event_triggered(event_type: String)

# Event types
enum EventType {
	# Original events
	LIGHT_FLICKER,
	SCREEN_GLITCH,
	WHISPER,
	OBJECT_MOVE,
	CLERK_STARE,
	SHADOW_PASS,
	STATIC_BURST,
	INTERCOM_VOICE,
	# New creepy events
	DOOR_KNOCK,        # Mysterious knocking on office door
	PHONE_RING,        # Phantom phone rings
	FOOTSTEPS,         # Footsteps when alone
	BREATHING,         # Sound of breathing nearby
	MONITOR_FACE,      # Face flashes on monitor
	CEILING_SCRATCH,   # Scratching from above
	CHAIR_MOVE,        # Chair moves on its own
	PAPER_RUSTLE,      # Papers move by themselves
	CLOCK_STOP,        # All clocks stop at once
	COLD_BREATH,       # Player sees their breath (cold spot)
	REFLECTION_WRONG,  # Something wrong in reflection
	NAME_CALLED,       # Player's name whispered
	EYES_WATCHING,     # Feeling of being watched
	BLOOD_TYPING       # Text appears blood-red on screen
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
var clerk: Node3D = null

# Horror audio system
var horror_audio: Node = null

func _ready() -> void:
	_setup_horror_audio()
	_load_settings()
	set_process(true)

func _setup_horror_audio() -> void:
	var audio_script = load("res://scripts/HorrorAudio.gd")
	if audio_script:
		horror_audio = Node.new()
		horror_audio.set_script(audio_script)
		horror_audio.name = "HorrorAudio"
		add_child(horror_audio)
		horror_audio.start_ambient_drone()
		print("[Horror] Audio system initialized")

func _load_settings() -> void:
	var save_node = get_node_or_null("/root/Save")
	if save_node:
		if "jumpscares_enabled" in save_node:
			jumpscares_enabled = bool(save_node.jumpscares_enabled)
		if "screenshake_enabled" in save_node:
			screenshake_enabled = bool(save_node.screenshake_enabled)
	print("[Horror] Settings loaded - Jumpscares: %s, Screenshake: %s" % [jumpscares_enabled, screenshake_enabled])

func _process(delta: float) -> void:
	if not jumpscares_enabled:
		return
	
	# Update audio tension
	if horror_audio and horror_audio.has_method("set_tension"):
		horror_audio.set_tension(tension_level)
	
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
	
	# Early shifts: only subtle events (shifts 1-3)
	if current_shift <= 3:
		available_events = [
			EventType.LIGHT_FLICKER, 
			EventType.WHISPER,
			EventType.PAPER_RUSTLE,
			EventType.CLOCK_STOP
		]
	# Mid shifts: moderate events (shifts 4-6)
	elif current_shift <= 6:
		available_events = [
			EventType.LIGHT_FLICKER, 
			EventType.WHISPER,
			EventType.SCREEN_GLITCH,
			EventType.OBJECT_MOVE,
			EventType.DOOR_KNOCK,
			EventType.FOOTSTEPS,
			EventType.PAPER_RUSTLE,
			EventType.CHAIR_MOVE,
			EventType.COLD_BREATH
		]
	# Late shifts: intense events (shifts 7-8)
	elif current_shift <= 8:
		available_events = [
			EventType.LIGHT_FLICKER,
			EventType.SCREEN_GLITCH,
			EventType.WHISPER,
			EventType.CLERK_STARE,
			EventType.SHADOW_PASS,
			EventType.STATIC_BURST,
			EventType.INTERCOM_VOICE,
			EventType.DOOR_KNOCK,
			EventType.PHONE_RING,
			EventType.FOOTSTEPS,
			EventType.BREATHING,
			EventType.CEILING_SCRATCH,
			EventType.CHAIR_MOVE,
			EventType.NAME_CALLED,
			EventType.EYES_WATCHING
		]
	# Endgame: ALL events including terrifying ones (shifts 9-10)
	else:
		available_events = [
			EventType.LIGHT_FLICKER,
			EventType.SCREEN_GLITCH,
			EventType.WHISPER,
			EventType.CLERK_STARE,
			EventType.SHADOW_PASS,
			EventType.STATIC_BURST,
			EventType.INTERCOM_VOICE,
			EventType.DOOR_KNOCK,
			EventType.PHONE_RING,
			EventType.FOOTSTEPS,
			EventType.BREATHING,
			EventType.MONITOR_FACE,
			EventType.CEILING_SCRATCH,
			EventType.CHAIR_MOVE,
			EventType.CLOCK_STOP,
			EventType.COLD_BREATH,
			EventType.REFLECTION_WRONG,
			EventType.NAME_CALLED,
			EventType.EYES_WATCHING,
			EventType.BLOOD_TYPING
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
		# New horror events
		EventType.DOOR_KNOCK:
			_do_door_knock()
		EventType.PHONE_RING:
			_do_phone_ring()
		EventType.FOOTSTEPS:
			_do_footsteps()
		EventType.BREATHING:
			_do_breathing()
		EventType.MONITOR_FACE:
			_do_monitor_face()
		EventType.CEILING_SCRATCH:
			_do_ceiling_scratch()
		EventType.CHAIR_MOVE:
			_do_chair_move()
		EventType.PAPER_RUSTLE:
			_do_paper_rustle()
		EventType.CLOCK_STOP:
			_do_clock_stop()
		EventType.COLD_BREATH:
			_do_cold_breath()
		EventType.REFLECTION_WRONG:
			_do_reflection_wrong()
		EventType.NAME_CALLED:
			_do_name_called()
		EventType.EYES_WATCHING:
			_do_eyes_watching()
		EventType.BLOOD_TYPING:
			_do_blood_typing()
	
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
	if horror_audio and horror_audio.has_method("play_whisper"):
		horror_audio.play_whisper()
	
	print("[Horror] *whisper*... did you hear that?")

func _do_object_move() -> void:
	# Play creak sound
	if horror_audio and horror_audio.has_method("play_creak"):
		horror_audio.play_creak()
	print("[Horror] Something moved in the corner of your eye...")

func _do_clerk_stare() -> void:
	# Clerk turns to look at player
	if horror_audio and horror_audio.has_method("play_heartbeat"):
		horror_audio.play_heartbeat()
	
	if clerk and clerk.has_method("creepy_head_snap") and camera:
		clerk.creepy_head_snap(camera)
	
	print("[Horror] The clerk is staring at you...")

func _do_shadow_pass() -> void:
	# Brief shadow crosses screen
	if screenshake_enabled:
		_screen_shake(0.1, 0.02)
	if horror_audio and horror_audio.has_method("play_whisper"):
		horror_audio.play_whisper()
	print("[Horror] A shadow passes by...")

func _do_static_burst() -> void:
	if horror_audio and horror_audio.has_method("play_static"):
		horror_audio.play_static()
	
	# Brief static on screen
	if environment:
		var tween = create_tween()
		tween.tween_property(environment, "glow_intensity", 2.0, 0.02)
		tween.tween_property(environment, "glow_intensity", 0.2, 0.1)

func _do_intercom_voice() -> void:
	# Play distorted voice
	if horror_audio and horror_audio.has_method("play_static"):
		horror_audio.play_static()
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
			if horror_audio and horror_audio.has_method("play_creak"):
				horror_audio.play_creak()
		"medium":
			trigger_event(EventType.SCREEN_GLITCH)
			if horror_audio and horror_audio.has_method("play_stinger"):
				horror_audio.play_stinger(0.3)
			await get_tree().create_timer(0.5).timeout
			trigger_event(EventType.WHISPER)
		"high":
			if horror_audio and horror_audio.has_method("play_stinger"):
				horror_audio.play_stinger(0.8)
			trigger_event(EventType.STATIC_BURST)
			await get_tree().create_timer(0.3).timeout
			trigger_event(EventType.SCREEN_GLITCH)
			if screenshake_enabled:
				_screen_shake(0.5, 0.1)

# ============================================
# NEW HORROR EVENT IMPLEMENTATIONS
# ============================================

func _do_door_knock() -> void:
	# Mysterious knocking from the office door
	if horror_audio and horror_audio.has_method("play_door_knock"):
		horror_audio.play_door_knock()
	else:
		# Fallback to creak if door knock not available
		if horror_audio and horror_audio.has_method("play_creak"):
			horror_audio.play_creak()
	
	# Brief pause, then second knock
	await get_tree().create_timer(0.8).timeout
	if horror_audio and horror_audio.has_method("play_door_knock"):
		horror_audio.play_door_knock()
	
	print("[Horror] *KNOCK* *KNOCK* Someone at the door...")

func _do_phone_ring() -> void:
	# Phantom phone ring - phone isn't connected
	if horror_audio and horror_audio.has_method("play_phone_ring"):
		horror_audio.play_phone_ring()
	else:
		if horror_audio and horror_audio.has_method("play_static"):
			horror_audio.play_static()
	
	# Light flicker coincides with ring
	if not office_lights.is_empty():
		var light = office_lights[randi() % office_lights.size()]
		var tween = create_tween()
		tween.tween_property(light, "light_energy", 0.3, 0.1)
		tween.tween_property(light, "light_energy", light.light_energy, 0.2)
	
	print("[Horror] The disconnected phone is ringing...")

func _do_footsteps() -> void:
	# Footsteps when player should be alone
	if horror_audio and horror_audio.has_method("play_footsteps"):
		horror_audio.play_footsteps()
	else:
		if horror_audio and horror_audio.has_method("play_creak"):
			# Multiple creaks to simulate steps
			for i in range(3):
				horror_audio.play_creak()
				await get_tree().create_timer(0.4).timeout
	
	# Subtle screen shake as if someone walking
	if screenshake_enabled:
		_screen_shake(0.3, 0.01)
	
	print("[Horror] Footsteps behind you...")

func _do_breathing() -> void:
	# Sound of breathing very close
	if horror_audio and horror_audio.has_method("play_breathing"):
		horror_audio.play_breathing()
	else:
		if horror_audio and horror_audio.has_method("play_whisper"):
			horror_audio.play_whisper()
	
	# Very slight camera movement as if something is there
	if camera and screenshake_enabled:
		var original = camera.rotation
		var tween = create_tween()
		tween.tween_property(camera, "rotation:y", original.y + 0.01, 0.5)
		tween.tween_property(camera, "rotation:y", original.y, 0.5)
	
	print("[Horror] You feel breath on your neck...")

func _do_monitor_face() -> void:
	# A face appears briefly on the monitor
	if horror_audio and horror_audio.has_method("play_stinger"):
		horror_audio.play_stinger(0.6)
	
	# Screen glitch effect
	if environment:
		var tween = create_tween()
		tween.tween_property(environment, "glow_intensity", 3.0, 0.05)
		tween.tween_property(environment, "glow_intensity", 0.2, 0.2)
	
	if screenshake_enabled:
		_screen_shake(0.15, 0.05)
	
	print("[Horror] A face stares back from the monitor...")

func _do_ceiling_scratch() -> void:
	# Scratching sounds from above
	if horror_audio and horror_audio.has_method("play_scratch"):
		horror_audio.play_scratch()
	else:
		if horror_audio and horror_audio.has_method("play_creak"):
			horror_audio.play_creak()
	
	# Lights flicker slightly
	if not office_lights.is_empty():
		for light in office_lights:
			var original = light.light_energy
			var tween = create_tween()
			tween.tween_property(light, "light_energy", original * 0.8, 0.1)
			tween.tween_property(light, "light_energy", original, 0.2)
	
	print("[Horror] Something scratches the ceiling...")

func _do_chair_move() -> void:
	# Empty chair moves on its own
	if horror_audio and horror_audio.has_method("play_creak"):
		horror_audio.play_creak()
	
	# Find chair in scene and move it slightly
	var chair = get_node_or_null("../OfficeChair")
	if chair:
		var original_pos = chair.position
		var tween = create_tween()
		tween.tween_property(chair, "position:x", original_pos.x + 0.1, 0.3)
		tween.tween_property(chair, "rotation:y", chair.rotation.y + 0.2, 0.5)
	
	print("[Horror] The chair moved on its own...")

func _do_paper_rustle() -> void:
	# Papers move/rustle without wind
	if horror_audio and horror_audio.has_method("play_paper_rustle"):
		horror_audio.play_paper_rustle()
	else:
		if horror_audio and horror_audio.has_method("play_whisper"):
			horror_audio.play_whisper()
	
	print("[Horror] Papers rustle... there's no wind here...")

func _do_clock_stop() -> void:
	# All clocks stop at the same time
	if horror_audio and horror_audio.has_method("play_static"):
		horror_audio.play_static()
	
	# Dim all lights briefly
	if not office_lights.is_empty():
		for light in office_lights:
			var original = light.light_energy
			var tween = create_tween()
			tween.tween_property(light, "light_energy", original * 0.5, 0.5)
			await get_tree().create_timer(2.0).timeout
			tween.tween_property(light, "light_energy", original, 0.3)
	
	print("[Horror] All the clocks stopped at the same time...")

func _do_cold_breath() -> void:
	# Player sees their breath - it's suddenly very cold
	if environment:
		var tween = create_tween()
		# Add blue-ish tint
		var original_adjustment = environment.adjustment_saturation if environment.adjustment_enabled else 1.0
		environment.adjustment_enabled = true
		tween.tween_property(environment, "adjustment_saturation", 0.5, 0.5)
		await get_tree().create_timer(2.0).timeout
		tween.tween_property(environment, "adjustment_saturation", original_adjustment, 0.5)
	
	if horror_audio and horror_audio.has_method("play_whisper"):
		horror_audio.play_whisper()
	
	print("[Horror] You can see your breath... it's freezing...")

func _do_reflection_wrong() -> void:
	# Something is wrong in the reflection
	if horror_audio and horror_audio.has_method("play_stinger"):
		horror_audio.play_stinger(0.4)
	
	if environment:
		var tween = create_tween()
		tween.tween_property(environment, "glow_intensity", 1.5, 0.1)
		tween.tween_property(environment, "glow_intensity", 0.2, 0.3)
	
	print("[Horror] Your reflection... it moved differently...")

func _do_name_called() -> void:
	# Player's name whispered
	if horror_audio and horror_audio.has_method("play_whisper"):
		horror_audio.play_whisper()
	
	await get_tree().create_timer(0.5).timeout
	
	if horror_audio and horror_audio.has_method("play_whisper"):
		horror_audio.play_whisper()
	
	print("[Horror] Someone whispered your name...")

func _do_eyes_watching() -> void:
	# Feeling of being watched - clerk stares but from wrong angle
	if horror_audio and horror_audio.has_method("play_heartbeat"):
		horror_audio.play_heartbeat()
	
	increase_tension(0.1)
	
	# Darken the environment slightly
	if not office_lights.is_empty():
		for light in office_lights:
			var original = light.light_energy
			var tween = create_tween()
			tween.tween_property(light, "light_energy", original * 0.7, 1.0)
			await get_tree().create_timer(3.0).timeout
			tween.tween_property(light, "light_energy", original, 1.0)
	
	print("[Horror] Eyes are watching you from somewhere...")

func _do_blood_typing() -> void:
	# Text appears blood-red on screen
	if horror_audio and horror_audio.has_method("play_stinger"):
		horror_audio.play_stinger(0.7)
	
	if environment:
		var tween = create_tween()
		tween.tween_property(environment, "glow_intensity", 2.5, 0.1)
		# Red tint
		environment.adjustment_enabled = true
		tween.tween_property(environment, "adjustment_saturation", 1.5, 0.1)
		await get_tree().create_timer(0.5).timeout
		tween.tween_property(environment, "glow_intensity", 0.2, 0.3)
		tween.tween_property(environment, "adjustment_saturation", 1.0, 0.3)
	
	if screenshake_enabled:
		_screen_shake(0.3, 0.08)
	
	print("[Horror] The text turns blood red...")


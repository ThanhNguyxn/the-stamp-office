extends Node
## HorrorAudio - Procedural horror sounds and ambient audio
## Generates creepy sounds without needing external audio files

signal sound_played(sound_type: String)

# Audio generators
var ambient_player: AudioStreamPlayer
var horror_player: AudioStreamPlayer
var whisper_player: AudioStreamPlayer

# Procedural audio generators
var ambient_generator: AudioStreamGenerator
var horror_generator: AudioStreamGenerator

# Settings
var enabled := true
var volume_db := -10.0

# State
var ambient_playing := false
var tension_level := 0.0

# Sound timers
var next_creak_time := 0.0
var next_hum_time := 0.0
var next_whisper_time := 0.0

func _ready() -> void:
	_create_audio_players()
	_load_settings()

func _load_settings() -> void:
	var save_node = get_node_or_null("/root/Save")
	if save_node and "sfx_enabled" in save_node:
		enabled = bool(save_node.sfx_enabled)

func _create_audio_players() -> void:
	# Ambient drone player
	ambient_player = AudioStreamPlayer.new()
	ambient_player.bus = "Music"
	ambient_player.volume_db = -20
	add_child(ambient_player)
	
	# Horror stinger player
	horror_player = AudioStreamPlayer.new()
	horror_player.bus = "SFX"
	horror_player.volume_db = -8
	add_child(horror_player)
	
	# Whisper player
	whisper_player = AudioStreamPlayer.new()
	whisper_player.bus = "SFX"
	whisper_player.volume_db = -15
	add_child(whisper_player)

func _process(delta: float) -> void:
	if not enabled:
		return
	
	# Random ambient sounds
	next_creak_time -= delta
	next_hum_time -= delta
	next_whisper_time -= delta
	
	if next_creak_time <= 0:
		if randf() < 0.3 + tension_level * 0.2:
			play_creak()
		next_creak_time = randf_range(15.0, 45.0) / (1.0 + tension_level)
	
	if next_hum_time <= 0:
		if randf() < 0.2:
			play_electrical_hum()
		next_hum_time = randf_range(20.0, 60.0)
	
	if next_whisper_time <= 0 and tension_level > 0.3:
		if randf() < tension_level * 0.3:
			play_whisper()
		next_whisper_time = randf_range(30.0, 90.0) / tension_level

func set_tension(level: float) -> void:
	tension_level = clampf(level, 0.0, 1.0)

## Play a creaking sound (like old wood/metal)
func play_creak() -> void:
	if not enabled:
		return
	
	var stream = _generate_creak()
	if stream:
		horror_player.stream = stream
		horror_player.pitch_scale = randf_range(0.8, 1.2)
		horror_player.play()
		sound_played.emit("creak")

## Play electrical humming
func play_electrical_hum() -> void:
	if not enabled:
		return
	
	var stream = _generate_hum()
	if stream:
		ambient_player.stream = stream
		ambient_player.play()
		sound_played.emit("hum")

## Play whisper sound
func play_whisper() -> void:
	if not enabled:
		return
	
	var stream = _generate_whisper()
	if stream:
		whisper_player.stream = stream
		whisper_player.pitch_scale = randf_range(0.7, 1.0)
		whisper_player.play()
		sound_played.emit("whisper")

## Play static burst
func play_static() -> void:
	if not enabled:
		return
	
	var stream = _generate_static()
	if stream:
		horror_player.stream = stream
		horror_player.volume_db = -5
		horror_player.play()
		sound_played.emit("static")

## Play heartbeat
func play_heartbeat() -> void:
	if not enabled:
		return
	
	var stream = _generate_heartbeat()
	if stream:
		horror_player.stream = stream
		horror_player.play()
		sound_played.emit("heartbeat")

## Play horror stinger (jumpscare sound)
func play_stinger(intensity: float = 0.5) -> void:
	if not enabled:
		return
	
	var stream = _generate_stinger(intensity)
	if stream:
		horror_player.stream = stream
		horror_player.volume_db = -3
		horror_player.play()
		sound_played.emit("stinger")

## Play door knock sound
func play_door_knock() -> void:
	if not enabled:
		return
	
	var stream = _generate_knock()
	if stream:
		horror_player.stream = stream
		horror_player.volume_db = -6
		horror_player.play()
		sound_played.emit("door_knock")

## Play phone ring (old rotary phone style)
func play_phone_ring() -> void:
	if not enabled:
		return
	
	var stream = _generate_phone_ring()
	if stream:
		horror_player.stream = stream
		horror_player.volume_db = -8
		horror_player.play()
		sound_played.emit("phone_ring")

## Play footstep sounds
func play_footsteps() -> void:
	if not enabled:
		return
	
	var stream = _generate_footstep()
	if stream:
		horror_player.stream = stream
		horror_player.volume_db = -12
		horror_player.pitch_scale = randf_range(0.9, 1.1)
		horror_player.play()
		sound_played.emit("footsteps")

## Play breathing sound
func play_breathing() -> void:
	if not enabled:
		return
	
	var stream = _generate_breathing()
	if stream:
		whisper_player.stream = stream
		whisper_player.volume_db = -18
		whisper_player.play()
		sound_played.emit("breathing")

## Play scratching sound
func play_scratch() -> void:
	if not enabled:
		return
	
	var stream = _generate_scratch()
	if stream:
		horror_player.stream = stream
		horror_player.volume_db = -10
		horror_player.play()
		sound_played.emit("scratch")

## Play paper rustling sound
func play_paper_rustle() -> void:
	if not enabled:
		return
	
	var stream = _generate_paper_rustle()
	if stream:
		ambient_player.stream = stream
		ambient_player.volume_db = -15
		ambient_player.play()
		sound_played.emit("paper_rustle")

## Play low drone for tension
func play_tension_drone() -> void:
	if not enabled:
		return
	
	var stream = _generate_tension_drone()
	if stream:
		ambient_player.stream = stream
		ambient_player.volume_db = -25
		ambient_player.play()
		sound_played.emit("tension_drone")

# === Procedural Audio Generation ===

func _generate_creak() -> AudioStreamWAV:
	var sample_rate := 22050
	var duration := randf_range(0.3, 0.8)
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	
	var freq := randf_range(80, 200)
	var freq_drift := randf_range(-30, 30)
	
	for i in samples:
		var t := float(i) / sample_rate
		var env := (1.0 - t / duration) * (1.0 - t / duration)
		var current_freq := freq + freq_drift * sin(t * 5)
		var sample := sin(t * current_freq * TAU) * 0.3
		sample += sin(t * current_freq * 2.1 * TAU) * 0.2
		sample += (randf() - 0.5) * 0.1 * env
		sample *= env
		
		var value := int(clampf(sample, -1.0, 1.0) * 32767)
		data[i * 2] = value & 0xFF
		data[i * 2 + 1] = (value >> 8) & 0xFF
	
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func _generate_hum() -> AudioStreamWAV:
	var sample_rate := 22050
	var duration := randf_range(2.0, 4.0)
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	
	var base_freq := 60.0  # Electrical hum frequency
	
	for i in samples:
		var t := float(i) / sample_rate
		var fade_in := minf(t / 0.5, 1.0)
		var fade_out := minf((duration - t) / 0.5, 1.0)
		var env := fade_in * fade_out
		
		var sample := sin(t * base_freq * TAU) * 0.15
		sample += sin(t * base_freq * 2 * TAU) * 0.08
		sample += sin(t * base_freq * 3 * TAU) * 0.04
		sample *= env
		
		var value := int(clampf(sample, -1.0, 1.0) * 32767)
		data[i * 2] = value & 0xFF
		data[i * 2 + 1] = (value >> 8) & 0xFF
	
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func _generate_whisper() -> AudioStreamWAV:
	var sample_rate := 22050
	var duration := randf_range(0.5, 1.5)
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	
	for i in samples:
		var t := float(i) / sample_rate
		var env := sin(t / duration * PI)  # Smooth fade in/out
		
		# Filtered white noise for whisper
		var noise := (randf() - 0.5) * 0.4
		# Simple low-pass filter effect
		var freq_mod := sin(t * randf_range(2, 8)) * 0.3 + 0.5
		var sample := noise * env * freq_mod
		
		var value := int(clampf(sample, -1.0, 1.0) * 32767)
		data[i * 2] = value & 0xFF
		data[i * 2 + 1] = (value >> 8) & 0xFF
	
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func _generate_static() -> AudioStreamWAV:
	var sample_rate := 22050
	var duration := randf_range(0.2, 0.5)
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	
	for i in samples:
		var t := float(i) / sample_rate
		var env := 1.0 - t / duration
		var sample := (randf() - 0.5) * 0.8 * env
		
		var value := int(clampf(sample, -1.0, 1.0) * 32767)
		data[i * 2] = value & 0xFF
		data[i * 2 + 1] = (value >> 8) & 0xFF
	
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func _generate_heartbeat() -> AudioStreamWAV:
	var sample_rate := 22050
	var duration := 1.5
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	
	for i in samples:
		var t := float(i) / sample_rate
		var sample := 0.0
		
		# Two beats
		var beat1 := exp(-pow((t - 0.1) * 15, 2)) * sin(t * 40 * TAU)
		var beat2 := exp(-pow((t - 0.25) * 15, 2)) * sin(t * 35 * TAU) * 0.7
		sample = (beat1 + beat2) * 0.5
		
		var value := int(clampf(sample, -1.0, 1.0) * 32767)
		data[i * 2] = value & 0xFF
		data[i * 2 + 1] = (value >> 8) & 0xFF
	
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func _generate_stinger(intensity: float) -> AudioStreamWAV:
	var sample_rate := 22050
	var duration := 0.3 + intensity * 0.3
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	
	var base_freq := 200 + intensity * 300
	
	for i in samples:
		var t := float(i) / sample_rate
		var env := exp(-t * (3 + intensity * 5))
		
		# Dissonant chord
		var sample := sin(t * base_freq * TAU) * 0.3
		sample += sin(t * base_freq * 1.5 * TAU) * 0.2  # Tritone
		sample += sin(t * base_freq * 0.75 * TAU) * 0.15
		sample += (randf() - 0.5) * 0.3 * env  # Noise
		sample *= env * intensity
		
		var value := int(clampf(sample, -1.0, 1.0) * 32767)
		data[i * 2] = value & 0xFF
		data[i * 2 + 1] = (value >> 8) & 0xFF
	
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

## Start ambient drone
func start_ambient_drone() -> void:
	if not enabled:
		return
	ambient_playing = true
	next_creak_time = randf_range(5.0, 15.0)
	next_hum_time = randf_range(10.0, 30.0)

## Stop all sounds
func stop_all() -> void:
	ambient_playing = false
	if ambient_player:
		ambient_player.stop()
	if horror_player:
		horror_player.stop()
	if whisper_player:
		whisper_player.stop()

# ============================================
# NEW PROCEDURAL AUDIO GENERATORS
# ============================================

func _generate_knock() -> AudioStreamWAV:
	var sample_rate := 22050
	var duration := 0.15
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	
	for i in samples:
		var t := float(i) / sample_rate
		var env := exp(-t * 30)  # Sharp attack, quick decay
		
		# Wooden knock sound - mix of frequencies
		var sample := sin(t * 180 * TAU) * 0.4
		sample += sin(t * 320 * TAU) * 0.2
		sample += sin(t * 520 * TAU) * 0.1
		sample += (randf() - 0.5) * 0.3 * env  # Impact noise
		sample *= env
		
		var value := int(clampf(sample, -1.0, 1.0) * 32767)
		data[i * 2] = value & 0xFF
		data[i * 2 + 1] = (value >> 8) & 0xFF
	
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func _generate_phone_ring() -> AudioStreamWAV:
	var sample_rate := 22050
	var duration := 1.0
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	
	for i in samples:
		var t := float(i) / sample_rate
		# Classic phone ring pattern - two frequencies alternating
		var ring_on := fmod(t, 0.1) < 0.05
		var env := 1.0 if ring_on else 0.0
		env *= sin(t / duration * PI)  # Fade in/out
		
		var sample := sin(t * 440 * TAU) * 0.3
		sample += sin(t * 480 * TAU) * 0.3
		sample *= env
		
		var value := int(clampf(sample, -1.0, 1.0) * 32767)
		data[i * 2] = value & 0xFF
		data[i * 2 + 1] = (value >> 8) & 0xFF
	
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func _generate_footstep() -> AudioStreamWAV:
	var sample_rate := 22050
	var duration := 0.2
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	
	for i in samples:
		var t := float(i) / sample_rate
		var env := exp(-t * 15)
		
		# Low thud with some higher frequencies
		var sample := sin(t * 80 * TAU) * 0.5 * env
		sample += sin(t * 120 * TAU) * 0.2 * env
		sample += (randf() - 0.5) * 0.4 * exp(-t * 30)  # Impact noise
		
		var value := int(clampf(sample, -1.0, 1.0) * 32767)
		data[i * 2] = value & 0xFF
		data[i * 2 + 1] = (value >> 8) & 0xFF
	
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func _generate_breathing() -> AudioStreamWAV:
	var sample_rate := 22050
	var duration := 2.5
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	
	for i in samples:
		var t := float(i) / sample_rate
		# Breathing rhythm - inhale and exhale
		var breath_phase := fmod(t, 1.2)
		var env := 0.0
		if breath_phase < 0.5:
			env = sin(breath_phase / 0.5 * PI)  # Inhale
		elif breath_phase < 0.6:
			env = 0.1  # Pause
		else:
			env = sin((breath_phase - 0.6) / 0.6 * PI) * 0.8  # Exhale
		
		# Filtered noise for breath sound
		var sample := (randf() - 0.5) * 0.4 * env
		# Add some low frequency rumble
		sample += sin(t * 30 * TAU) * 0.1 * env
		
		var value := int(clampf(sample, -1.0, 1.0) * 32767)
		data[i * 2] = value & 0xFF
		data[i * 2 + 1] = (value >> 8) & 0xFF
	
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func _generate_scratch() -> AudioStreamWAV:
	var sample_rate := 22050
	var duration := randf_range(0.5, 1.0)
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	
	var scratch_freq := randf_range(2000, 4000)
	
	for i in samples:
		var t := float(i) / sample_rate
		var env := sin(t / duration * PI)  # Smooth in/out
		env *= 0.5 + 0.5 * sin(t * randf_range(3, 8) * TAU)  # Irregular
		
		# High frequency scratching noise
		var sample := (randf() - 0.5) * 0.6 * env
		sample += sin(t * scratch_freq * TAU) * 0.1 * env
		
		var value := int(clampf(sample, -1.0, 1.0) * 32767)
		data[i * 2] = value & 0xFF
		data[i * 2 + 1] = (value >> 8) & 0xFF
	
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func _generate_paper_rustle() -> AudioStreamWAV:
	var sample_rate := 22050
	var duration := randf_range(0.3, 0.7)
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	
	for i in samples:
		var t := float(i) / sample_rate
		var env := sin(t / duration * PI)
		
		# High-pass filtered noise for paper sound
		var sample := (randf() - 0.5) * 0.3
		# Irregular volume changes
		sample *= 0.3 + 0.7 * abs(sin(t * randf_range(10, 30) * TAU))
		sample *= env
		
		var value := int(clampf(sample, -1.0, 1.0) * 32767)
		data[i * 2] = value & 0xFF
		data[i * 2 + 1] = (value >> 8) & 0xFF
	
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func _generate_tension_drone() -> AudioStreamWAV:
	var sample_rate := 22050
	var duration := 5.0
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	
	var base_freq := 40.0  # Very low frequency
	
	for i in samples:
		var t := float(i) / sample_rate
		var fade_in := minf(t / 1.0, 1.0)
		var fade_out := minf((duration - t) / 1.0, 1.0)
		var env := fade_in * fade_out
		
		# Ominous low drone with subtle modulation
		var freq_mod := 1.0 + 0.02 * sin(t * 0.5 * TAU)
		var sample := sin(t * base_freq * freq_mod * TAU) * 0.3
		sample += sin(t * base_freq * 1.5 * TAU) * 0.15  # Fifth
		sample += sin(t * base_freq * 2.0 * TAU) * 0.1   # Octave
		# Add subtle beating
		sample *= 1.0 + 0.1 * sin(t * 2 * TAU)
		sample *= env
		
		var value := int(clampf(sample, -1.0, 1.0) * 32767)
		data[i * 2] = value & 0xFF
		data[i * 2 + 1] = (value >> 8) & 0xFF
	
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

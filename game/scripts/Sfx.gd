extends Node
## Sfx - Procedural audio synthesis for game sounds
## Uses AudioStreamGenerator to create sounds without external assets

var enabled: bool = true
var sample_rate: float = 44100.0

# Audio players for different sounds
var click_player: AudioStreamPlayer
var stamp_player: AudioStreamPlayer
var error_player: AudioStreamPlayer
var glitch_player: AudioStreamPlayer

func _ready() -> void:
	# Create audio players
	click_player = _create_player()
	stamp_player = _create_player()
	error_player = _create_player()
	glitch_player = _create_player()

func _create_player() -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new()
	var stream = AudioStreamGenerator.new()
	stream.mix_rate = sample_rate
	stream.buffer_length = 0.2
	player.stream = stream
	player.volume_db = -6.0  # Conservative volume
	add_child(player)
	return player

## Enable or disable all sound effects
func set_enabled(on: bool) -> void:
	enabled = on

## Play a soft click sound (for buttons)
func play_click() -> void:
	if not enabled:
		return
	_play_tone(click_player, 800, 0.05, 0.8)

## Play stamp sound (approved = higher pitch, denied = lower)
func play_stamp(approved: bool) -> void:
	if not enabled:
		return
	var freq = 400 if approved else 200
	_play_tone(stamp_player, freq, 0.15, 0.6, true)

## Play error/warning sound
func play_error() -> void:
	if not enabled:
		return
	_play_tone(error_player, 150, 0.2, 0.5, false, true)

## Play glitch sound (subtle, horror-ish)
func play_glitch() -> void:
	if not enabled:
		return
	_play_noise(glitch_player, 0.1, 0.3)

## Generate and play a simple tone
func _play_tone(player: AudioStreamPlayer, freq: float, duration: float, 
		volume: float = 1.0, decay: bool = false, wobble: bool = false) -> void:
	if not player or not player.stream:
		return
	
	player.play()
	var playback = player.get_stream_playback()
	if not playback:
		return
	
	var samples = int(sample_rate * duration)
	var phase = 0.0
	var increment = freq / sample_rate
	
	for i in range(samples):
		var t = float(i) / samples
		var env = 1.0 - t if decay else (1.0 - t * 0.5)  # Envelope
		
		# Optional wobble for error sound
		var current_freq = freq
		if wobble:
			current_freq = freq + sin(t * 30) * 50
			increment = current_freq / sample_rate
		
		# Generate square-ish wave (softer than pure square)
		var sample = sin(phase * TAU) * 0.7 + sin(phase * TAU * 2) * 0.2
		sample *= env * volume * 0.3  # Keep it quiet
		
		playback.push_frame(Vector2(sample, sample))
		phase += increment
		if phase >= 1.0:
			phase -= 1.0

## Generate noise burst (for glitch)
func _play_noise(player: AudioStreamPlayer, duration: float, volume: float = 0.3) -> void:
	if not player or not player.stream:
		return
	
	player.play()
	var playback = player.get_stream_playback()
	if not playback:
		return
	
	var samples = int(sample_rate * duration)
	
	for i in range(samples):
		var t = float(i) / samples
		var env = 1.0 - t  # Decay envelope
		
		# Generate filtered noise
		var noise = (randf() * 2.0 - 1.0) * env * volume * 0.2
		
		# Add some low frequency rumble
		noise += sin(t * 100) * 0.1 * env
		
		playback.push_frame(Vector2(noise, noise))

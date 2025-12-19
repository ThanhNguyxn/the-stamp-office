extends Node
## ShiftEvents - Random interrupt events during shifts
## Absurd office horror-comedy interruptions with 2 choices

signal event_started()
signal event_ended(mood_delta: int, contradiction_delta: int)

# Event timer
var event_timer: Timer
var min_interval: float = 20.0
var max_interval: float = 45.0

# Current event state
var active: bool = false
var current_event: Dictionary = {}

# Pool of events (PG-13, international-friendly, no real brands)
var events: Array = [
	{
		"title": "🖨️ PRINTER JAM",
		"body": "The office printer is making concerning noises.\nPaper is everywhere. What do you do?",
		"choice_a": "Smack it",
		"choice_b": "Stay calm",
		"result_a": {"mood": 1, "contradiction": 1, "toast": "Violence is never the answer... but it worked."},
		"result_b": {"mood": 0, "contradiction": 0, "toast": "A moment of zen in the chaos."}
	},
	{
		"title": "💬 BOSS PING",
		"body": "Your supervisor has marked a message as 'URGENT!!!!'\nIt's about the quarterly report. Again.",
		"choice_a": "Reply instantly",
		"choice_b": "Pretend offline",
		"result_a": {"mood": -1, "contradiction": 0, "toast": "Good employee. Continue stamping."},
		"result_b": {"mood": 1, "contradiction": 2, "toast": "Your silence has been noted."}
	},
	{
		"title": "☕ COFFEE SITUATION",
		"body": "Someone left fresh coffee in the break room.\nThe aroma is... suspicious.",
		"choice_a": "Drink it",
		"choice_b": "Stay sober",
		"result_a": {"mood": 2, "contradiction": 1, "toast": "Energy acquired. Side effects pending."},
		"result_b": {"mood": -1, "contradiction": 0, "toast": "Safety first. Productivity second."}
	},
	{
		"title": "🔔 FIRE DRILL (MAYBE)",
		"body": "The alarm is ringing. Or is it?\nNo one else is moving.",
		"choice_a": "Comply",
		"choice_b": "Stamp faster",
		"result_a": {"mood": -1, "contradiction": -1, "toast": "Protocol followed. Desk abandoned."},
		"result_b": {"mood": 0, "contradiction": 2, "toast": "The system appreciates dedication."}
	},
	{
		"title": "📞 PHONE RINGING",
		"body": "An unknown extension is calling.\nIt's been ringing for 5 minutes.",
		"choice_a": "Answer",
		"choice_b": "Ignore",
		"result_a": {"mood": -1, "contradiction": 1, "toast": "Wrong number. Of course."},
		"result_b": {"mood": 0, "contradiction": 1, "toast": "Silence is compliance."}
	},
	{
		"title": "📋 AUDIT NOTICE",
		"body": "A memo appeared on your desk:\n'Your workstation will be audited shortly.'",
		"choice_a": "Panic clean",
		"choice_b": "Accept fate",
		"result_a": {"mood": -2, "contradiction": 0, "toast": "Spotless desk. Suspicious behavior."},
		"result_b": {"mood": 0, "contradiction": 1, "toast": "They see everything anyway."}
	},
	{
		"title": "💡 FLICKERING LIGHT",
		"body": "The fluorescent light above you is flickering.\nMaintenance says it's 'within acceptable parameters.'",
		"choice_a": "Fix it yourself",
		"choice_b": "Endure",
		"result_a": {"mood": 1, "contradiction": 2, "toast": "Unauthorized maintenance logged."},
		"result_b": {"mood": -1, "contradiction": 0, "toast": "Character building."}
	},
	{
		"title": "🎵 HOLD MUSIC",
		"body": "The elevator music is playing louder today.\nMuch louder. No one knows why.",
		"choice_a": "Complain",
		"choice_b": "Embrace it",
		"result_a": {"mood": 0, "contradiction": 1, "toast": "Complaint filed. Status: Pending."},
		"result_b": {"mood": 1, "contradiction": 0, "toast": "You've learned to love the loop."}
	}
]

func _ready() -> void:
	# Create and configure timer
	event_timer = Timer.new()
	event_timer.one_shot = true
	event_timer.timeout.connect(_on_timer_timeout)
	add_child(event_timer)

## Start the event system
func start() -> void:
	_schedule_next_event()

## Stop the event system
func stop() -> void:
	event_timer.stop()

## Schedule next random event
func _schedule_next_event() -> void:
	var delay = randf_range(min_interval, max_interval)
	event_timer.start(delay)

## Timer triggered - show random event
func _on_timer_timeout() -> void:
	if active:
		return
	
	# Pick a random event
	current_event = events[randi() % events.size()]
	active = true
	emit_signal("event_started")

## Get current event data
func get_current_event() -> Dictionary:
	return current_event

## Player made a choice
func choose(choice: String) -> Dictionary:
	if not active:
		return {}
	
	var result: Dictionary
	if choice == "A":
		result = current_event.get("result_a", {})
	else:
		result = current_event.get("result_b", {})
	
	active = false
	var mood_delta = result.get("mood", 0)
	var contradiction_delta = result.get("contradiction", 0)
	
	emit_signal("event_ended", mood_delta, contradiction_delta)
	
	# Schedule next event
	_schedule_next_event()
	
	return result

## Check if an event is active
func is_active() -> bool:
	return active

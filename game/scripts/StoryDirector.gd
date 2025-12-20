extends Node
## StoryDirector - Delivers intercom/memo lines at key moments
## Per-shift scripted messages for story immersion + horror triggers

signal story_message(text: String, is_intercom: bool)
signal trigger_horror(intensity: String)  # "low", "medium", "high"

# Story lines per shift (embedded from docs/script/)
const SHIFT_LINES = {
	1: {
		"start": "📢 Welcome to The Office. Your first day. Please process all tickets.",
		"mid": "📢 Remember: The rules are your friends. Mostly.",
		"end": "📢 Shift complete. You may clock out. Tomorrow will be... different."
	},
	2: {
		"start": "📢 Day two. The forms have changed. Slightly. Pay attention.",
		"mid": "📢 Have you noticed the walls? No? Good. Keep working.",
		"end": "📢 Another shift survived. The Office appreciates your compliance."
	},
	3: {
		"start": "📢 Some stamps don't exist. Yet. Ignore that.",
		"mid": "📢 The Break Room is closed for 'maintenance.' Do not investigate.",
		"end": "📢 You're doing well. Too well? No. Just well."
	},
	4: {
		"start": "📢 Reality is stable. Probably. Process your tickets.",
		"mid": "📢 If you hear voices, they are The Office speaking. Listen.",
		"end": "📢 Four shifts. You're almost... something. Keep going."
	},
	5: {
		"start": "📢 NOT A THING is not a stamp. Ignore this message.",
		"mid": "📢 Kevin from Accounting says hello. Kevin does not exist.",
		"end": "📢 Halfway there. The Office is watching. Proudly? Perhaps."
	},
	6: {
		"start": "📢 Rule 0: There is no Rule 0. Proceed normally.",
		"mid": "📢 The Archive contains files. Do not read them. Too late?",
		"end": "📢 Six days. Your paperwork is... affecting things. Good things?"
	},
	7: {
		"start": "📢 Level 7 requests are sensitive. Deny with caution. Or don't.",
		"mid": "📢 The elevator has always been broken. Always.",
		"end": "📢 Seven shifts. Almost done. The walls remember you now."
	},
	8: {
		"start": "📢 A drawer may open. You didn't see anything inside.",
		"mid": "📢 Some tickets want... something else. Give it to them?",
		"end": "📢 Three more days. The void acknowledges your progress."
	},
	9: {
		"start": "📢 Kevin knows the door. Ask nicely. Or don't ask at all.",
		"mid": "📢 Requesting acknowledgment of the void. That's... a ticket?",
		"end": "📢 Tomorrow is your last day. Unless it isn't. It probably is."
	},
	10: {
		"start": "📢 Final shift. Whatever happens... thank you for your service.",
		"mid": "📢 Some things are not things. And that's... something.",
		"end": "📢 ..."
	}
}

var current_shift: int = 1
var message_index: int = 0  # 0=start shown, 1=mid shown, 2=end shown

func set_shift(shift_number: int) -> void:
	current_shift = clampi(shift_number, 1, 10)
	message_index = 0

func get_start_message() -> String:
	if SHIFT_LINES.has(current_shift):
		return SHIFT_LINES[current_shift].get("start", "")
	return ""

func get_mid_message() -> String:
	if SHIFT_LINES.has(current_shift):
		return SHIFT_LINES[current_shift].get("mid", "")
	return ""

func get_end_message() -> String:
	if SHIFT_LINES.has(current_shift):
		return SHIFT_LINES[current_shift].get("end", "")
	return ""

## Call when shift starts
func on_shift_start() -> void:
	var msg = get_start_message()
	if msg != "":
		story_message.emit(msg, true)
		message_index = 1
	
	# Horror trigger for later shifts
	if current_shift >= 5:
		await get_tree().create_timer(3.0).timeout
		trigger_horror.emit("low")

## Call at mid-shift (e.g., ticket 4/12 or 6/12)
func on_mid_shift() -> void:
	if message_index >= 1:
		var msg = get_mid_message()
		if msg != "":
			story_message.emit(msg, true)
			message_index = 2
		
		# Mid-shift horror escalation
		if current_shift >= 6:
			await get_tree().create_timer(2.0).timeout
			trigger_horror.emit("medium")
		elif current_shift >= 3:
			await get_tree().create_timer(2.0).timeout
			trigger_horror.emit("low")

## Call when shift ends
func on_shift_end() -> void:
	var msg = get_end_message()
	if msg != "":
		story_message.emit(msg, true)
		message_index = 3
	
	# End-of-shift climactic horror
	if current_shift >= 8:
		await get_tree().create_timer(1.5).timeout
		trigger_horror.emit("high")
	elif current_shift >= 5:
		await get_tree().create_timer(1.5).timeout
		trigger_horror.emit("medium")

## Trigger horror for specific story moments
func trigger_story_moment(moment_id: String) -> void:
	match moment_id:
		"kevin_mention":
			trigger_horror.emit("low")
		"void_acknowledgment":
			trigger_horror.emit("medium")
		"not_a_thing":
			trigger_horror.emit("high")
		"final_revelation":
			trigger_horror.emit("high")
			await get_tree().create_timer(1.0).timeout
			trigger_horror.emit("medium")

extends Node
## StoryDirector - Delivers intercom/memo lines at key moments
## Per-shift scripted messages for story immersion + horror triggers

signal story_message(text: String, is_intercom: bool)
signal trigger_horror(intensity: String)  # "low", "medium", "high"
signal ambient_message(text: String)  # Random ambient creepy messages

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

# Random ambient messages that can appear at any time
const AMBIENT_MESSAGES = {
	# Subtle/Early game (Shifts 1-4)
	"subtle": [
		"The coffee machine makes a strange sound.",
		"A pen rolls off your desk.",
		"The clock ticks louder than usual.",
		"Someone coughs in the distance. You're alone.",
		"The fluorescent light buzzes.",
		"A paper falls from somewhere unseen.",
		"The air conditioning whispers.",
		"Your chair creaks unexpectedly.",
		"A phone rings in an empty office.",
		"The printer prints by itself.",
		"You smell something burning. Nothing is.",
		"A drawer was open. You closed it. It's open again.",
	],
	# Unsettling/Mid game (Shifts 5-7)
	"unsettling": [
		"The shadows seem longer today.",
		"Someone was standing there. Now they're not.",
		"The walls feel closer than before.",
		"Your reflection blinked first.",
		"The clock shows a time that doesn't exist.",
		"Something scratches behind the wall.",
		"The exit sign flickers in morse code.",
		"A door that wasn't there is now.",
		"The carpet has new stains. They look fresh.",
		"Someone wrote your name on a sticky note.",
		"The office plant turned toward you.",
		"You hear typing. Your hands are still.",
		"The elevator dings. There is no elevator.",
		"Kevin's desk is empty. It always was.",
		"A photograph is face-down. You didn't touch it.",
	],
	# Terrifying/Late game (Shifts 8-10)
	"terrifying": [
		"The walls are breathing.",
		"Your stamp left a mark on your hand.",
		"Something is following you between the cubicles.",
		"The void acknowledged your existence.",
		"Time moved backwards. Just for a second.",
		"The office extends further than the building.",
		"You found a ticket with tomorrow's date. And your name.",
		"The Clerk smiled. The Clerk can't smile.",
		"Reality.exe has encountered an error.",
		"The coffee tastes like yesterday's regrets.",
		"Something under your desk grabbed your ankle. Maybe.",
		"The ceiling drips something that isn't water.",
		"You hear your own voice from the hallway.",
		"The windows show a different sky.",
		"Employee of the Month has your face. Wrong face.",
		"A door opened to a room full of your chairs.",
		"The filing cabinet contains a file about you.",
		"There are too many desks now.",
	]
}

# Random intercom announcements (distorted, creepy)
const RANDOM_INTERCOM = [
	"📢 *STATIC* ...do not... *CRACKLE* ...remain calm...",
	"📢 The previous employee is no longer. Continue working.",
	"📢 Reminder: Personal items will be... absorbed.",
	"📢 The Office thanks you for your continued existence.",
	"📢 Attention: Time is relative. Your deadline is not.",
	"📢 *BZZT* Kevin... *STATIC* ...never existed... *CRACKLE*",
	"📢 Floor 13 is open for business. There is no Floor 13.",
	"📢 Your performance review has been rescheduled. Indefinitely.",
	"📢 The Break Room has been relocated. Do not search.",
	"📢 All employees are real. Confirmation pending.",
	"📢 *INTERFERENCE* ...help... *STATIC* ...me...",
	"📢 Overtime is mandatory. Time is optional.",
	"📢 Your replacement has arrived. Disregard this message.",
	"📢 The Office is proud of your... compliance?",
	"📢 Remember: You chose to be here. Probably.",
]

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

## Get a random ambient message based on current shift intensity
func get_random_ambient_message() -> String:
	var category := "subtle"
	if current_shift >= 8:
		# Late game: mostly terrifying, sometimes unsettling
		category = "terrifying" if randf() > 0.2 else "unsettling"
	elif current_shift >= 5:
		# Mid game: mostly unsettling, sometimes subtle
		category = "unsettling" if randf() > 0.3 else "subtle"
	else:
		# Early game: mostly subtle
		category = "subtle"
	
	var messages: Array = AMBIENT_MESSAGES.get(category, [])
	if messages.is_empty():
		return ""
	return messages[randi() % messages.size()]

## Get a random intercom announcement
func get_random_intercom() -> String:
	if RANDOM_INTERCOM.is_empty():
		return ""
	return RANDOM_INTERCOM[randi() % RANDOM_INTERCOM.size()]

## Trigger a random ambient event (call periodically during gameplay)
func trigger_random_ambient() -> void:
	# 60% chance ambient message, 40% chance intercom
	if randf() < 0.6:
		var msg = get_random_ambient_message()
		if msg != "":
			ambient_message.emit(msg)
	else:
		var msg = get_random_intercom()
		if msg != "":
			story_message.emit(msg, true)
			# Random intercom sometimes triggers horror
			if current_shift >= 4 and randf() < 0.3:
				await get_tree().create_timer(1.0).timeout
				trigger_horror.emit("low")

## Call this when player makes a mistake (wrong stamp, etc.)
func on_player_mistake() -> void:
	# Chance of creepy message on mistake
	if randf() < 0.4:
		var messages := [
			"That was... incorrect.",
			"The Office noticed that.",
			"Someone is disappointed.",
			"Errors are remembered.",
			"The void grows slightly.",
		]
		ambient_message.emit(messages[randi() % messages.size()])
	
	if current_shift >= 5 and randf() < 0.3:
		trigger_horror.emit("low")

## Call this when player approves something suspicious
func on_suspicious_approval() -> void:
	if current_shift >= 3:
		var messages := [
			"You approved that?",
			"Interesting choice.",
			"The paperwork accepts your decision.",
			"Someone somewhere smiled.",
		]
		ambient_message.emit(messages[randi() % messages.size()])
	
	if current_shift >= 6 and randf() < 0.4:
		await get_tree().create_timer(0.5).timeout
		trigger_horror.emit("medium")

## Special event for shift 10 - the finale builds tension
func trigger_finale_sequence() -> void:
	var finale_messages := [
		"The Office has enjoyed your service.",
		"All tickets have been processed.",
		"Time to collect your final paycheck.",
		"The door is open now.",
		"Thank you for everything.",
		"...",
	]
	
	for i in finale_messages.size():
		story_message.emit("📢 " + finale_messages[i], true)
		
		if i >= 3:
			trigger_horror.emit("high")
		elif i >= 1:
			trigger_horror.emit("medium")
		
		await get_tree().create_timer(3.0).timeout

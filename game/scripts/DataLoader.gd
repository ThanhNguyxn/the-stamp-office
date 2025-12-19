extends Node
## DataLoader - Loads JSON data from game/data/
## Registered as autoload in project.godot

var _toasts: Dictionary = {}
var _rules: Array = []

func _ready() -> void:
	_load_toasts()
	_load_rules()

## Load toasts from JSON
func _load_toasts() -> void:
	var file = FileAccess.open("res://data/toasts/toasts.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		if json.parse(file.get_as_text()) == OK:
			var data = json.get_data()
			for t in data.get("toasts", []):
				_toasts[t["id"]] = t["text"]
		file.close()

## Load rules from JSON
func _load_rules() -> void:
	var file = FileAccess.open("res://data/rules/rules.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		if json.parse(file.get_as_text()) == OK:
			var data = json.get_data()
			_rules = data.get("rules", [])
		file.close()

## Load tickets for a specific shift
func load_shift(shift_number: int) -> Array:
	var path = "res://data/tickets/shift%02d.json" % shift_number
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var json = JSON.new()
		if json.parse(file.get_as_text()) == OK:
			var data = json.get_data()
			file.close()
			return data.get("tickets", [])
		file.close()
	return []

## Get toast text by ID
func toast_text(toast_id: String) -> String:
	return _toasts.get(toast_id, "Unknown: " + toast_id)

## Get rules for a specific shift (rules introduced in that shift or earlier)
func rules_for_shift(shift_number: int) -> Array:
	var result: Array = []
	for rule in _rules:
		if rule.get("shift", 99) <= shift_number:
			result.append(rule)
	return result

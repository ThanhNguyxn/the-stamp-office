extends Node
## DataLoader - Loads JSON data from game/data/
## Registered as autoload in project.godot

var _toasts: Dictionary = {}

func _ready() -> void:
	_load_toasts()

func _load_toasts() -> void:
	var file = FileAccess.open("res://data/toasts/toasts.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		if json.parse(file.get_as_text()) == OK:
			var data = json.get_data()
			for t in data.get("toasts", []):
				_toasts[t["id"]] = t["text"]
		file.close()

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

func toast_text(toast_id: String) -> String:
	return _toasts.get(toast_id, "Unknown: " + toast_id)

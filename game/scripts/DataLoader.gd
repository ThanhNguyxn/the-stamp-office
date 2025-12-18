extends Node
## DataLoader - Loads JSON data from the data folder
## Add to Project Settings > Autoload as "DataLoader"

var _toasts_cache: Dictionary = {}
var _loaded: bool = false

func _ready() -> void:
	_load_toasts()

func _load_toasts() -> void:
	var path = "res://data/toasts/toasts.json"
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		file.close()
		if error == OK:
			var data = json.get_data()
			for toast in data.get("toasts", []):
				_toasts_cache[toast["id"]] = toast["text"]
			_loaded = true
			print("DataLoader: Loaded ", _toasts_cache.size(), " toasts")
		else:
			push_error("DataLoader: Failed to parse toasts.json")
	else:
		push_error("DataLoader: Could not open toasts.json at ", path)

func load_shift(shift_number: int) -> Array:
	var path = "res://data/tickets/shift%02d.json" % shift_number
	var file = FileAccess.open(path, FileAccess.READ)
	
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		file.close()
		if error == OK:
			var data = json.get_data()
			var tickets = data.get("tickets", [])
			print("DataLoader: Loaded ", tickets.size(), " tickets from shift ", shift_number)
			return tickets
		else:
			push_error("DataLoader: Failed to parse shift", shift_number, ".json")
	else:
		push_error("DataLoader: Could not open ", path)
	
	return []

func toast_text(toast_id: String) -> String:
	# Lazy load toasts if not yet loaded
	if not _loaded:
		_load_toasts()
	
	if _toasts_cache.has(toast_id):
		return _toasts_cache[toast_id]
	return "Unknown toast: " + toast_id

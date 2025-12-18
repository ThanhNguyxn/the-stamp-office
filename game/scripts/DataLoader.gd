extends Node
## DataLoader - Loads JSON data from the data folder

const DATA_PATH = "res://../data/"

var _toasts_cache: Dictionary = {}
var _shift_cache: Dictionary = {}

func _ready() -> void:
	_load_toasts()

func _load_toasts() -> void:
	var path = DATA_PATH + "toasts/toasts.json"
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		if error == OK:
			var data = json.get_data()
			for toast in data.get("toasts", []):
				_toasts_cache[toast["id"]] = toast["text"]
		file.close()
	else:
		# Try alternative path for running from editor
		_load_toasts_fallback()

func _load_toasts_fallback() -> void:
	var path = "res://data/toasts/toasts.json"
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		if error == OK:
			var data = json.get_data()
			for toast in data.get("toasts", []):
				_toasts_cache[toast["id"]] = toast["text"]
		file.close()

func load_shift(shift_num: int) -> Array:
	var path = DATA_PATH + "tickets/shift%02d.json" % shift_num
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		# Try alternative path
		path = "res://data/tickets/shift%02d.json" % shift_num
		file = FileAccess.open(path, FileAccess.READ)
	
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		file.close()
		if error == OK:
			var data = json.get_data()
			return data.get("tickets", [])
	return []

func load_shift01() -> Array:
	return load_shift(1)

func toast_text(toast_id: String) -> String:
	if _toasts_cache.has(toast_id):
		return _toasts_cache[toast_id]
	return "Toast not found: " + toast_id

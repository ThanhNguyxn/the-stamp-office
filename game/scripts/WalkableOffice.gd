extends Node3D
## WalkableOffice - Full office map with multiple rooms
## Based on MAP SPEC: Desk Room, Corridor, Archive, Printer Room, Break Rooms

signal room_entered(room_name: String)
signal door_interacted(door_name: String, is_open: bool)
signal prop_interacted(prop_name: String)

# Room unlock progression based on shift
var room_unlock_shifts := {
	"desk_room": 1,
	"corridor": 1,
	"archive": 2,
	"printer_room": 3,
	"break_room_a": 4,
	"break_room_b": 7,
	"manager_door": 10  # Never opens, just for show
}

var doors := {}
var current_room := "desk_room"
var unlocked_max_shift := 1

@onready var player: CharacterBody3D = $Player

func _ready() -> void:
	# Get unlocked shifts from Save
	var save_node = get_node_or_null("/root/Save")
	if save_node and "unlocked_max_shift" in save_node:
		unlocked_max_shift = int(save_node.unlocked_max_shift)
	
	_setup_doors()
	_update_room_access()

func _setup_doors() -> void:
	# Find all door nodes and cache them
	for child in get_children():
		if child.name.begins_with("Door_"):
			doors[child.name] = child
			if child.has_signal("interacted"):
				child.interacted.connect(_on_door_interacted)

func _update_room_access() -> void:
	# Enable/disable rooms based on progression
	for room_name in room_unlock_shifts:
		var required_shift = room_unlock_shifts[room_name]
		var is_unlocked = unlocked_max_shift >= required_shift
		
		# Find room node and update
		var room_node = get_node_or_null(room_name.to_pascal_case())
		if room_node:
			room_node.set_meta("unlocked", is_unlocked)

func _on_door_interacted(door_name: String) -> void:
	var door = doors.get(door_name)
	if not door:
		return
	
	# Check if door leads to locked room
	var target_room = door.get_meta("target_room", "")
	if target_room != "":
		var required_shift = room_unlock_shifts.get(target_room, 1)
		if unlocked_max_shift < required_shift:
			# Door is locked
			_show_locked_message(target_room, required_shift)
			return
	
	# Toggle door
	if door.has_method("toggle"):
		door.toggle()
		door_interacted.emit(door_name, door.is_open)

func _show_locked_message(room_name: String, required_shift: int) -> void:
	print("[Office] Room '%s' locked until Shift %02d" % [room_name, required_shift])
	# TODO: Show UI toast message

func set_player_position(pos: Vector3) -> void:
	if player:
		player.global_position = pos

func get_current_room() -> String:
	return current_room

## Called when player enters a room trigger
func _on_room_entered(room_name: String) -> void:
	if room_name != current_room:
		current_room = room_name
		room_entered.emit(room_name)
		print("[Office] Entered: ", room_name)

extends StaticBody3D
## Door - Interactive door with open/close animations
## Can be locked based on progression

signal interacted(door_name: String)

@export var target_room: String = ""
@export var is_locked: bool = false
@export var locked_message: String = "This door is locked."
@export var open_angle: float = 90.0
@export var open_speed: float = 2.0

var is_open := false
var target_rotation := 0.0
var initial_rotation := 0.0

@onready var door_mesh: MeshInstance3D = $DoorMesh
@onready var interaction_area: Area3D = $InteractionArea

func _ready() -> void:
	initial_rotation = rotation_degrees.y
	target_rotation = initial_rotation
	
	if interaction_area:
		# Will be connected by player's interaction system
		pass
	
	set_meta("target_room", target_room)

func _process(delta: float) -> void:
	# Smooth door rotation
	var current_y = rotation_degrees.y
	if abs(current_y - target_rotation) > 0.1:
		rotation_degrees.y = lerp(current_y, target_rotation, open_speed * delta)

func interact() -> void:
	interacted.emit(name)

func toggle() -> void:
	if is_locked:
		# Play locked sound/shake
		_play_locked_effect()
		return
	
	is_open = !is_open
	target_rotation = initial_rotation + (open_angle if is_open else 0.0)
	
	# Play door sound
	_play_door_sound()

func open() -> void:
	if not is_locked and not is_open:
		is_open = true
		target_rotation = initial_rotation + open_angle
		_play_door_sound()

func close() -> void:
	if is_open:
		is_open = false
		target_rotation = initial_rotation
		_play_door_sound()

func set_locked(locked: bool) -> void:
	is_locked = locked

func _play_door_sound() -> void:
	# TODO: Play actual sound
	print("[Door] %s: %s" % [name, "opened" if is_open else "closed"])

func _play_locked_effect() -> void:
	# Shake door slightly
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees:y", initial_rotation + 2, 0.05)
	tween.tween_property(self, "rotation_degrees:y", initial_rotation - 2, 0.05)
	tween.tween_property(self, "rotation_degrees:y", initial_rotation + 1, 0.05)
	tween.tween_property(self, "rotation_degrees:y", initial_rotation, 0.05)
	print("[Door] %s: LOCKED - %s" % [name, locked_message])

## For external queries
func can_interact() -> bool:
	return true

func get_interaction_hint() -> String:
	if is_locked:
		return "[E] Locked"
	return "[E] " + ("Close" if is_open else "Open")

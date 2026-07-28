extends Node

func _ready() -> void:
	setup_inputs()

static func setup_inputs() -> void:
	_ensure_action("move_left", [
		_create_key_event(KEY_A),
		_create_key_event(KEY_LEFT),
		_create_joy_button_event(JOY_BUTTON_DPAD_LEFT),
		_create_joy_motion_event(JOY_AXIS_LEFT_X, -1.0)
	])
	
	_ensure_action("move_right", [
		_create_key_event(KEY_D),
		_create_key_event(KEY_RIGHT),
		_create_joy_button_event(JOY_BUTTON_DPAD_RIGHT),
		_create_joy_motion_event(JOY_AXIS_LEFT_X, 1.0)
	])

	_ensure_action("jump", [
		_create_key_event(KEY_SPACE),
		_create_key_event(KEY_W),
		_create_key_event(KEY_UP),
		_create_joy_button_event(JOY_BUTTON_A) # PlayStation X / Xbox A
	])

	_ensure_action("backdash", [
		_create_key_event(KEY_L),
		_create_joy_button_event(JOY_BUTTON_Y) # PlayStation Triangle / Xbox Y
	])

	_ensure_action("attack", [
		_create_key_event(KEY_J),
		_create_key_event(KEY_X),
		_create_joy_button_event(JOY_BUTTON_X) # PlayStation Square / Xbox X
	])

static func _ensure_action(action_name: StringName, events: Array) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	
	for event in events:
		if event and not InputMap.action_has_event(action_name, event):
			InputMap.action_add_event(action_name, event)

static func _create_key_event(keycode: Key) -> InputEventKey:
	var ev = InputEventKey.new()
	ev.physical_keycode = keycode
	return ev

static func _create_joy_button_event(button: JoyButton) -> InputEventJoypadButton:
	var ev = InputEventJoypadButton.new()
	ev.button_index = button
	return ev

static func _create_joy_motion_event(axis: JoyAxis, value: float) -> InputEventJoypadMotion:
	var ev = InputEventJoypadMotion.new()
	ev.axis = axis
	ev.axis_value = value
	return ev

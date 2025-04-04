extends CharacterBody2D

@export var speed = 200
var target_position
var path = []
var following_path = false

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			target_position = get_global_mouse_position()
			path = []
			following_path = false
			print("Left mouse button pressed. Clearing path and stopping following.")
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				print("Right mouse button pressed. Starting to record path.")
				path = []
				path.append(get_global_mouse_position())
				following_path = true
			else:
				print("Right mouse button released. Continuing to follow path.")
				following_path = true
			print("Following path: %s" % following_path)
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		if following_path:
			var mouse_pos = get_global_mouse_position()
			path.append(mouse_pos)
			print("Added point to path: %s. Current path length: %d" % [mouse_pos, path.size()])
		else:
			print("Mouse moved while right button is pressed, but not following path.")

extends Node

var win_x : int = 1280
var win_y : int = 720
# Called when the node enters the scene tree for the first time.
func _ready():
		set_window_size(win_x,win_y)
		return



func set_window_size(width: int, height: int):
	print("change_sie")
	DisplayServer.window_set_size(Vector2i(width, height))
	var screen_size = DisplayServer.screen_get_size()
	print(screen_size)
	DisplayServer.window_set_position(Vector2i(0,30))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

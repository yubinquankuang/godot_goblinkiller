extends Node

var win_x : int = 1920
var win_y : int = 1080
# Called when the node enters the scene tree for the first time.
func _ready():
		set_window_size(win_x,win_y)
		return



func set_window_size(width: int, height: int):
	#print("change_sie")
	#DisplayServer.get_primary_screen()
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	#DisplayServer.window_set_size(Vector2i(width, height))
	return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

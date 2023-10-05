extends VBoxContainer


func start_game():
	print("start game")
	get_tree().change_scene_to_file("res://mainScence.tscn")
	
func quit_game():
	print("end game")
	get_tree().quit()

# Called when the node enters the scene tree for the first time.
func _ready():
	$start.pressed.connect(self.start_game)
	$end.pressed.connect(self.quit_game)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



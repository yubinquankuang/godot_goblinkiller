extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var jk = [1,2,2,3,3,3,3,4,4,5,6]
	jk.remove_at(5)
	print(jk)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

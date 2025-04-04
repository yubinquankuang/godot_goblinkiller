extends Node2D

@onready var button = $Button
@onready var sprite_2d = $CharacterBody2D/Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	sprite_2d.self_modulate = Color.BLACK
	print("change color green",sprite_2d.modulate)

extends Node2D


var path_line: Line2D
var path:Array[Vector2] = []
@export var origin_position = Vector2(0,0)
@onready var point_conatiner = $PointConatiner
var current_pos:Vector2 = Vector2.ZERO
var current_index = 0
var npc_pos = Vector2(150,60)
var line_continue = false
var min_distance = 10
var click_num = 0

func _ready():
	path_line = Line2D.new()
	path_line.default_color = Color(1, 0, 0)
	path_line.width = 2
	path_line.z_index = 10
	add_child(path_line)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			click_num += 1
			current_pos = get_global_mouse_position()
			if Input.is_key_pressed(KEY_SHIFT):
				if not line_continue:
					line_continue = true
					clear_line_points()
				
				current_index = path.size()
				if current_index == 0:
					path.append(npc_pos)
					path_line.add_point(npc_pos)
					current_index += 1
				if current_pos.distance_to(path[current_index-1]) < min_distance:
					print('extend distance')
					return
				path.append(current_pos)
				path_line.add_point(current_pos)
				draw_point(current_pos)
				current_index += 1
			else:
				print("right button click")
				line_continue = false
				clear_line_points()
				path.append(npc_pos)
				path_line.add_point(npc_pos)
				current_index += 1
				if current_pos.distance_to(path[current_index-1]) < min_distance:
						print('extend distance')
						return
				else:
					path.append(current_pos)
					path_line.add_point(current_pos)
					draw_point(current_pos)
					current_index += 1
					
func clear_line_points():
	path.clear()
	current_index = 0
	path_line.clear_points()
	for point in point_conatiner.get_children():
		point.queue_free()
			
func draw_point(position: Vector2):
	var circle = CircleShape2D.new()
	circle.radius = 8 # 点的半径
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = circle
	collision_shape.position = position
	point_conatiner.add_child(collision_shape)

extends CharacterBody2D

signal path_complated(index)

const SPEED = 32
const JUMP_VELOCITY = -400.0

var target_position
var path = []
var following_path = false
var current_point_index = 0

@export_range(0, 1, 0.1) var pic_red: float = 1.0
@export_range(0, 1, 0.1) var pic_green: float = 1.0
@export_range(0, 1, 0.1) var pic_blue: float = 1.0
@export_range(0, 1, 0.1) var pic_alpha: float = 1.0

@onready var tilemap = $"../TileMapLayer2"
@onready var map = $".."
@onready var pic: Sprite2D = $Sprite2D

func _ready():
	#path_line = Line2D.new()
	#path_line.default_color = Color(1, 0, 0)
	#path_line.width = 2
	#path_line.z_index = 10  # 设置较高的 z_index 确保在其他节点之上渲染
	#get_tree().root.add_child(path_line)
	print("Line2D node created and added to the scene root.")
	connect("path_complated", Callable(map, "_on_path_complated"))

func _process(delta):
	#if path_line and str(path_line.get_path()) != "":
		#print("Path of the Line2D node in the node tree:", path_line.get_path())
		# 只打印一次，避免重复输出
		#set_process(false)
		return

func _physics_process(delta):
	pic.modulate = Color(pic_red, pic_green, pic_blue, pic_alpha)
	pic.texture = load("res://assests/pic/npc/team2.png")
	var player_world_position = self.global_position
	var unit_speed = SPEED
	if tilemap:
		var tile_coordinate = tilemap.local_to_map(player_world_position)
		var tile_data = tilemap.get_cell_tile_data(Vector2i(tile_coordinate.x, tile_coordinate.y))
		if tile_data:
			unit_speed = tile_data.get_custom_data("speed") * SPEED
		else:
			unit_speed = SPEED

	if following_path and path.size() > 0:
		if current_point_index < path.size():
			var next_point = path[current_point_index]
			var direction = (next_point - position).normalized()
			#print("current points is ", path[current_point_index], " following is ",following_path, " index is ", current_point_index,"distance ",next_point - position)
			emit_signal("path_complated", current_point_index)
			if position.distance_to(next_point) > 5:
				velocity = direction * unit_speed
			else:
				current_point_index += 1
				if current_point_index >= path.size():
					following_path = false
					velocity = Vector2.ZERO
					path = []
					current_point_index = 0
				else:
	
					
					print("")
		else:
			following_path = false
			velocity = Vector2.ZERO
			path = []
			#path_line.points = []
			current_point_index = 0
	elif target_position:
		var direction = (target_position - position).normalized()
		if position.distance_to(target_position) > 5:
			velocity = direction * unit_speed
		else:
			target_position = null
			velocity = Vector2.ZERO

	move_and_slide()

# 处理接收到的路径信号的方法
func _on_path_selected(new_path):
	print("receive path:  ",new_path)
	path = new_path
	following_path = true
	current_point_index = 0
	
	print("Received path. Starting to follow.")

	

	

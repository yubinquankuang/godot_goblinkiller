extends Node2D

# 定义信号，用于发送路径给 team 节点
signal path_selected(path)

@onready var team: Node2D = $Team
@onready var map_land: TileMapLayer = $TileMapLayer
@onready var map_surface: TileMapLayer = $TileMapLayer2
@onready var path_line = $Line2D

var x_num = Setting.win_x / 16
var y_num = Setting.win_y / 16
var target_position
var path = []
var following_path = false
var current_point_index = 0

func _ready():
	draw_map()
	# 连接信号到 team 节点的相应方法
	connect("path_selected", Callable(team, "_on_path_selected"))

func draw_map():
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.05
	noise.fractal_lacunarity = 2.5

	var noise_image = noise.get_image(x_num * 2, y_num * 2, false, false, false)

	for y in range(y_num * 2):
		for x in range(x_num * 2):
			var noise_value = noise_image.get_pixel(x, y).r
			var tile_index = get_tile_index_from_noise(noise_value)
			map_land.set_cell(Vector2i(x - x_num, y - y_num), 1, Vector2i(tile_index / 2, 0))
			map_surface.set_cell(Vector2i(x - x_num, y - y_num), 1, Vector2i(tile_index / 2, 1 + tile_index / 4))

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			target_position = get_global_mouse_position()
			path = [target_position]  # 左键点击将点击位置作为路径
			path_line.points = path
			emit_signal("path_selected", path)  # 发送路径信号
			following_path = false
			current_point_index = 0
			print("Left mouse button pressed. Sending path and clearing local path.")
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				print("Right mouse button pressed. Starting to record path.")
				path = []  # 清空之前的路径点
				path.append(get_global_mouse_position())
				path_line.points = path
				following_path = false
			else:
				print("Right mouse button released. Sending path.")
				if path.size() > 0:
					emit_signal("path_selected", path)  # 发送路径信号
					following_path = false
			print("Following path: %s" % following_path)
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		if not following_path:
			var mouse_pos = get_global_mouse_position()
			path.append(mouse_pos)
			path_line.points = path
			print("Path line points after mouse motion:", path_line.points)
			print("Added point to path: %s. Current path length: %d" % [mouse_pos, path.size()])
		else:
			print("Mouse moved while right button is pressed, but already following path.")

func get_tile_index_from_noise(noise_value: float) -> int:
	if noise_value < 0.2:
		return 0
	elif noise_value < 0.3:
		return 1
	elif noise_value < 0.4:
		return 2
	elif noise_value < 0.5:
		return 3
	elif noise_value < 0.6:
		return 4
	elif noise_value < 0.7:
		return 5
	elif noise_value < 0.8:
		return 6
	else:
		return 7
	

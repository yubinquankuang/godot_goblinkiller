extends Node2D

# 定义信号，用于发送路径给 team 节点
signal path_selected(path)

@onready var team: Node2D = $Team
@onready var map_land: TileMapLayer = $TileMapLayer
@onready var map_surface: TileMapLayer = $TileMapLayer2
@onready var path_line = $Line2D
@onready var point_container: Node2D = $PointContainer
@onready var selection_rect: Node2D = $SelectionRect

var x_num = Setting.win_x / 16
var y_num = Setting.win_y / 16
var target_position
var path = []
var following_path = false
var current_point_index = 0

const DISTANCE_THRESHOLD = 10 # 距离阈值
const TIME_INTERVAL = 0.1 # 时间间隔
const ANGLE_THRESHOLD = 30 # 角度阈值，用于过滤偏差过大的点

var drawing_path = false
var last_recorded_point: Vector2
var last_record_time: float

# 新增：拉框选择相关变量
var is_dragging = false
var drag_start: Vector2 = Vector2.ZERO
var selected_nodes = []

func _ready():
	draw_map()
	# 连接信号到 team 节点的相应方法
	connect("path_selected", Callable(team, "_on_path_selected"))
	# 修改：设置 Line2D 的属性，使用 default_color
	path_line.width = 2 
	path_line.default_color = Color(0.82, 1, 0.3)
	team.add_to_group("company_zero")

func draw_map():
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.05
	noise.fractal_lacunarity = 2.5

	var noise_image = noise.get_image(x_num * 2, y_num * 2)

	for y in range(y_num * 2):
		for x in range(x_num * 2):
			var noise_value = noise_image.get_pixel(x, y).r
			var tile_index = get_tile_index_from_noise(noise_value)
			map_land.set_cell(Vector2i(x - x_num, y - y_num), 1, Vector2i(tile_index / 2, 0))
			map_surface.set_cell(Vector2i(x - x_num, y - y_num), 1, Vector2i(tile_index / 2, 1 + tile_index / 4))

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			var mouse_pos = get_global_mouse_position()
			if Input.is_key_pressed(KEY_SHIFT):
				if path.size() == 0:
					path.append(team.position)
					path_line.add_point(team.position)
				path.append(mouse_pos)
				path_line.add_point(mouse_pos)
				print("Shift + Right mouse button pressed. Adding point to path.")
				draw_point(mouse_pos)
				following_path = false
			else:
				print("one click clear path")
				clear_path_line()
				target_position = mouse_pos
				draw_point(target_position)
				path = [team.position, target_position]  # 右键单击将点击位置作为路径
				path_line.clear_points()
				for p in path:
					path_line.add_point(p)
				current_point_index = 0
				emit_signal("path_selected", path)  # 发送路径信号
				following_path = true
				print("Right mouse button pressed. Sending single point path.")
		else:
			if Input.is_key_pressed(KEY_SHIFT) and path.size() > 1:
				print("Shift + Right mouse button released. Sending path.", path)
				emit_signal("path_selected", path)  # 发送路径信号
				following_path = true

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

func _on_path_complated(index: int):
	if index < path.size():
		path = path.slice(index)  # 更新本地路径
		path_line.points = path  # 更新 Line2D 的路径
		if point_container.get_child_count() > 0:
			var child = point_container.get_child(0)
			child.queue_free()
	else:
		clear_path_line()
		following_path = false
	print("Current path line points in _physics_process:", path_line.points)

func draw_point(position: Vector2):
	var circle = CircleShape2D.new()
	circle.radius = 2 # 点的半径
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = circle
	collision_shape.position = position
	point_container.add_child(collision_shape)

func clear_path_line():
	path.clear()
	path_line.clear_points()
	for child in point_container.get_children():
		child.queue_free()

func _physics_process(delta):
	if following_path and path.size() > 0:
		var current_point = path[current_point_index]
		var distance = team.position.distance_to(current_point)
		if distance < DISTANCE_THRESHOLD:
			current_point_index += 1
			if current_point_index < path.size():
				path = path.slice(current_point_index)
				path_line.points = path
				if point_container.get_child_count() > 0:
					var child = point_container.get_child(0)
					child.queue_free()
			else:
				clear_path_line()
				following_path = false
	# 新增检查，避免越界
	if current_point_index >= path.size():
		current_point_index = 0
		clear_path_line()
		following_path = false    

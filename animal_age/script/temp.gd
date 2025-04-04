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
var drawn_points = []
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
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if Input.is_key_pressed(KEY_SHIFT):
				if event.pressed:
					print("Shift + Right mouse button pressed. Adding point to path.")
					var mouse_pos = get_global_mouse_position()
					drawn_points.append(mouse_pos)
					last_recorded_point = mouse_pos
					last_record_time = Time.get_ticks_usec() / 1000000.0
					path_line.add_point(mouse_pos)
					draw_point(mouse_pos)
					following_path = false
				else:
					print("Shift + Right mouse button released. Continuing to draw path.")
			else:
				if not Input.is_key_pressed(KEY_SHIFT) and drawn_points.size() > 0:
					print("Shift released. Sending path.")
					path = process_line2d_points(drawn_points)
					var simplified_points = douglas_peucker(path, 2)
					if simplified_points.size() > 0:
						path = simplified_points  # 更新本地路径
						path_line.points = path  # 更新 Line2D 的路径
						emit_signal("path_selected", path)  # 发送路径信号
						following_path = true
						current_point_index = 0
					print("Following path: %s" % following_path)
					# 清除路径和点
					drawn_points.clear()
					path_line.clear_points()
					for child in point_container.get_children():
						child.queue_free()
				elif event.pressed:
					target_position = get_global_mouse_position()
					path = [target_position]  # 右键单击将点击位置作为路径
					path_line.points = path
					emit_signal("path_selected", path)  # 发送路径信号
					following_path = true
					current_point_index = 0
					print("Right mouse button pressed. Sending single point path.")

	elif event is InputEventMouseMotion:
		pass

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
	print("Current path line points in _physics_process:", path_line.points)

func process_line2d_points(points):
	path_line.clear_points()
	for child in point_container.get_children():
		child.queue_free()

	var new_points = []
	for point in points:
		var rounded_point = point.round()
		path_line.add_point(rounded_point)
		new_points.append(rounded_point)
		draw_point(rounded_point)
	return new_points

func draw_point(position: Vector2):
	var circle = CircleShape2D.new()
	circle.radius = 2 # 点的半径
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = circle
	collision_shape.position = position
	point_container.add_child(collision_shape)

# Douglas - Peucker 算法简化路径
func douglas_peucker(points, epsilon):
	var dmax = 0
	var index = 0
	for i in range(1, points.size() - 1):
		var d = perpendicular_distance(points[i], points[0], points[points.size() - 1])
		if d > dmax:
			index = i
			dmax = d

	if dmax > epsilon:
		var results1 = douglas_peucker(points.slice(0, index + 1), epsilon)
		var results2 = douglas_peucker(points.slice(index, points.size()), epsilon)
		results1.pop_back()
		# 修改：使用 append_array 替代 extend
		results1.append_array(results2)
		return results1
	else:
		return [points[0], points[points.size() - 1]]

# 计算点到直线的垂直距离
func perpendicular_distance(point, start, end):
	var numerator = abs((end.y - start.y) * point.x - (end.x - start.x) * point.y + end.x * start.y - end.y * start.x)
	var denominator = sqrt(pow(end.y - start.y, 2) + pow(end.x - start.x, 2))
	return numerator / denominator

func select_node(node: Node):
	if not selected_nodes.has(node):
		selected_nodes.append(node)
		# 查找子节点 Sprite2D 并设置选中效果
		var sprite = node.get_node("Sprite2D")
		if sprite:
			sprite.modulate = Color(1, 0, 0)

func deselect_all_nodes():
	for node in selected_nodes:
		var sprite = node.get_node("Sprite2D")
		if sprite:
			sprite.modulate = Color(1, 1, 1)
	selected_nodes.clear()

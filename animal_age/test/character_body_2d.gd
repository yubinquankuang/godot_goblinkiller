extends CharacterBody2D

# 移动速度
const SPEED = 60
# 每个小队最大士兵数量
const MAX_SOLDIERS_PER_SQUAD = 100
# 每个士兵的像素大小
const PIXEL_SIZE = 4
# 每个士兵的间距
const SOLDIER_SPACING = PIXEL_SIZE*1.5
# 用于计算边界的初始最大值
const INIT_MAX = 9999
# 用于计算边界的初始最小值
const INIT_MIN = -9999
# 行列数的最小和最大值
const MIN_ROWS_COLS = 1
const MAX_ROWS_COLS = 50

# 存储所有士兵的存活状态
var soldiers = []
# 存储存活士兵的索引
var alive_soldiers = []
# 阵型参数
@export var rows = 10
@export var cols = 10

# 碰撞形状节点
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready():
	# 初始化士兵状态
	for i in range(MAX_SOLDIERS_PER_SQUAD):
		soldiers.append(true)
		alive_soldiers.append(i)
	# 初始化碰撞形状
	update_collision_shape()
	_on_row_btn_pressed()
	print("士兵初始化完成，碰撞形状已更新")

func _physics_process(delta):
	# 获取水平方向输入
	var direction_x = Input.get_axis("ui_left", "ui_right")
	# 获取垂直方向输入
	var direction_y = Input.get_axis("ui_up", "ui_down")

	if direction_x != 0:
		# 每次只移动速度代表的像素
		position.x += direction_x * SPEED * delta
	elif direction_y != 0:
		position.y += direction_y * SPEED * delta

func _draw():
	# 绘制存活士兵的像素点
	for index in alive_soldiers:
		var row = index / cols
		var col = index % cols
		if row < rows:
			var pos = Vector2(col * SOLDIER_SPACING, row * SOLDIER_SPACING)
			draw_rect(Rect2(pos, Vector2(PIXEL_SIZE, PIXEL_SIZE)), Color(1, 0, 0))

func kill_random_soldier():
	# 随机杀死一名士兵
	if alive_soldiers.size() > 0:
		var random_index = randi() % alive_soldiers.size()
		var soldier_index = alive_soldiers[random_index]
		soldiers[soldier_index] = false
		alive_soldiers.erase(soldier_index)
		adjust_rows_cols()
		# 重绘画面
		queue_redraw()
		# 更新碰撞形状
		update_collision_shape()
		# 补位
		fill_empty_position()
		print("一名士兵死亡，画面和碰撞形状已更新，尝试补位")

func update_collision_shape():
	if alive_soldiers.size() == 0:
		# 如果没有存活士兵，禁用碰撞形状
		collision_shape.disabled = true
		print("没有存活士兵，碰撞形状已禁用")
		return
	else:
		collision_shape.disabled = false

	var min_x = INIT_MAX
	var min_y = INIT_MAX
	var max_x = INIT_MIN
	var max_y = INIT_MIN

	# 计算存活士兵的边界
	for index in alive_soldiers:
		var row = index / cols
		var col = index % cols
		if row < rows:
			var pos = Vector2(col * SOLDIER_SPACING, row * SOLDIER_SPACING)
			min_x = min(min_x, pos.x)
			min_y = min(min_y, pos.y)
			max_x = max(max_x, pos.x + PIXEL_SIZE)
			max_y = max(max_y, pos.y + PIXEL_SIZE)

	# 创建一个矩形碰撞形状
	var rect_shape = RectangleShape2D.new()
	rect_shape.extents = Vector2(max_x - min_x, max_y - min_y) / 2
	collision_shape.shape = rect_shape
	collision_shape.position = Vector2(min_x, min_y) + rect_shape.extents
	print("碰撞形状已更新")

func fill_empty_position():
	# 先确定最外围士兵的位置
	var perimeter_soldiers = []
	for index in alive_soldiers:
		var row = index / cols
		var col = index % cols
		if row < rows and (row == 0 or row == rows - 1 or col == 0 or col == cols - 1):
			perimeter_soldiers.append(index)

	# 找到第一个空位
	var empty_index = -1
	for i in range(MAX_SOLDIERS_PER_SQUAD):
		if not soldiers[i]:
			empty_index = i
			break

	if empty_index != -1:
		# 找到一个非外围的存活士兵来补位
		for index in alive_soldiers:
			var row = index / cols
			var col = index % cols
			if row < rows and row != 0 and row != rows - 1 and col != 0 and col != cols - 1:
				# 交换位置
				soldiers[empty_index] = true
				soldiers[index] = false
				alive_soldiers.erase(index)
				alive_soldiers.append(empty_index)
				alive_soldiers.sort()
				# 重绘画面
				queue_redraw()
				# 更新碰撞形状
				update_collision_shape()
				print("士兵补位完成，画面和碰撞形状已更新")
				break

func set_rows(new_rows):
	if new_rows < MIN_ROWS_COLS or new_rows > MAX_ROWS_COLS:
		print("行数超出范围，应为 1 - 20 之间")
		return
	rows = new_rows
	on_rows_cols_changed()
	print("行数已更新为", new_rows)

func set_cols(new_cols):
	if new_cols < MIN_ROWS_COLS or new_cols > MAX_ROWS_COLS:
		print("列数超出范围，应为 1 - 20 之间")
		return
	cols = new_cols
	on_rows_cols_changed()
	print("列数已更新为", new_cols)

func on_rows_cols_changed():
	# 重绘画面
	queue_redraw()
	# 更新碰撞形状
	update_collision_shape()
	print("行列数改变，画面和碰撞形状已更新")

func _on_button_pressed():
	# 按钮按下时，随机杀死一名士兵
	kill_random_soldier()

func _on_row_btn_pressed():
	rows = rows + 1
	cols = alive_soldiers.size() / rows
	if alive_soldiers.size() % rows > 0:
		cols += 1
	set_rows(rows)

func _on_col_btn_pressed():
	cols = cols + 1
	rows = alive_soldiers.size() / cols
	if alive_soldiers.size() / cols > 0:
		rows += 1
	set_cols(cols)

func adjust_rows_cols():
	var alive_count = alive_soldiers.size()
	while rows * cols > alive_count:
		if rows > cols:
			cols -= 1
		else:
			rows -= 1
	print("阵型缩减为", rows, "x", cols)

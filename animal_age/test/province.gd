extends Node2D

# 地图图像路径
const MAP_IMAGE_PATH = "res://assests/pic/map/China.png"

# 加载地图图像
var map_image = Image.new()
var processed_texture

# 自定义高斯模糊函数
func gaussian_blur_custom(image: Image, radius: int):
	var width = image.get_width()
	var height = image.get_height()
	var result = image.duplicate()
	var kernel_size = radius * 2 + 1
	var kernel = []

	# 生成高斯核
	var sigma = radius / 3.0
	var sum = 0.0
	for y in range(-radius, radius + 1):
		for x in range(-radius, radius + 1):
			var value = exp(-(x * x + y * y) / (2 * sigma * sigma))
			kernel.append(value)
			sum += value

	# 归一化高斯核
	for i in range(kernel.size()):
		kernel[i] /= sum

	for y in range(height):
		for x in range(width):
			var r = 0.0
			var g = 0.0
			var b = 0.0
			var index = 0
			for ky in range(-radius, radius + 1):
				for kx in range(-radius, radius + 1):
					var px = x + kx
					var py = y + ky
					if px >= 0 and px < width and py >= 0 and py < height:
						var color = image.get_pixel(px, py)
						r += color.r * kernel[index]
						g += color.g * kernel[index]
						b += color.b * kernel[index]
					index += 1
			result.set_pixel(x, y, Color(r, g, b))
	return result

func _ready():
	# 加载图像
	var load_result = map_image.load(MAP_IMAGE_PATH)
	if load_result != OK:
		print("Failed to load image from path: ", MAP_IMAGE_PATH)
		return

	var width = map_image.get_width()
	var height = map_image.get_height()
	if width == 0 or height == 0:
		print("Loaded image has invalid dimensions (width = ", width, ", height = ", height, ")")
		return

	var processed_image = Image.new()
	processed_image.create(width, height, false, Image.FORMAT_RGBA8)

	# 图像预处理：转换为灰度图并进行高斯模糊
	var gray_image = Image.new()
	gray_image.create(width, height, false, Image.FORMAT_R8)
	for y in range(height):
		for x in range(width):
			var color = map_image.get_pixel(x, y)
			var gray = (color.r + color.g + color.b) / 3
			gray_image.set_pixel(x, y, Color(gray, 0, 0))

	# 使用自定义高斯模糊算法
	var blurred_image = gaussian_blur_custom(gray_image, 3)

	# 边缘检测：使用 Canny 算法
	var edges_image = Image.new()
	edges_image.create(width, height, false, Image.FORMAT_R8)
	for y in range(1, height - 1):
		for x in range(1, width - 1):
			var center = blurred_image.get_pixel(x, y).r
			var left = blurred_image.get_pixel(x - 1, y).r
			var right = blurred_image.get_pixel(x + 1, y).r
			var top = blurred_image.get_pixel(x, y - 1).r
			var bottom = blurred_image.get_pixel(x, y + 1).r
			var gradient_x = right - left
			var gradient_y = bottom - top
			var gradient_magnitude = sqrt(gradient_x * gradient_x + gradient_y * gradient_y)
			if gradient_magnitude > 0.1:  # 阈值
				edges_image.set_pixel(x, y, Color(1, 0, 0))
			else:
				edges_image.set_pixel(x, y, Color(0, 0, 0))

	# 轮廓检测
	var contours = []
	var visited = {}
	for y in range(height):
		for x in range(width):
			if edges_image.get_pixel(x, y).r == 1 and!visited.has(Vector2(x, y)):
				var contour = []
				var stack = [Vector2(x, y)]
				while stack.size() > 0:
					var point = stack.pop_back()
					if visited.has(point) or point.x < 0 or point.x >= width or point.y < 0 or point.y >= height:
						continue
					visited[point] = true
					if edges_image.get_pixelv(point).r == 1:
						contour.append(point)
						stack.append(point + Vector2(1, 0))
						stack.append(point + Vector2(-1, 0))
						stack.append(point + Vector2(0, 1))
						stack.append(point + Vector2(0, -1))
				if contour.size() > 0:
					contours.append(contour)

	# 为每个轮廓区域填充不同颜色
	var color_index = 0
	var colors = [Color(1, 0, 0), Color(0, 1, 0), Color(0, 0, 1), Color(1, 1, 0)]
	for contour in contours:
		var flood_fill_queue = [contour[0]]
		var visited_fill = {}
		var current_color = colors[color_index % colors.size()]
		while flood_fill_queue.size() > 0:
			var point = flood_fill_queue.pop_back()
			if visited_fill.has(point) or point.x < 0 or point.x >= width or point.y < 0 or point.y >= height:
				continue
			visited_fill[point] = true
			if edges_image.get_pixelv(point).r == 0:
				processed_image.set_pixelv(point, current_color)
				flood_fill_queue.append(point + Vector2(1, 0))
				flood_fill_queue.append(point + Vector2(-1, 0))
				flood_fill_queue.append(point + Vector2(0, 1))
				flood_fill_queue.append(point + Vector2(0, -1))
		color_index += 1

	# 创建处理后的纹理
	processed_texture = ImageTexture.create_from_image(processed_image)

	# 创建 Sprite 节点显示处理后的图像
	var sprite = Sprite2D.new()
	sprite.texture = processed_texture
	add_child(sprite)

	

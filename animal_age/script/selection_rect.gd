extends Node2D

var is_dragging = false
var drag_start: Vector2 = Vector2.ZERO
var selection_rect: Rect2
var selected_nodes = []
var tween: Tween
var draw_rect_alpha = 1.0

func _ready():
	tween = get_tree().create_tween()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_start = get_global_mouse_position()
				draw_rect_alpha = 1.0
			else:
				is_dragging = false
				if drag_start != Vector2.ZERO:
					var drag_end = get_global_mouse_position()
					selection_rect = get_normalized_rect(Rect2(drag_start, drag_end - drag_start))
					select_nodes_in_rect()
					drag_start = Vector2.ZERO
					start_tween()

	elif event is InputEventMouseMotion:
		if is_dragging:
			queue_redraw()

func _draw():
	if is_dragging or draw_rect_alpha > 0:
		var rect = selection_rect
		if is_dragging:
			var current_pos = get_global_mouse_position()
			rect = get_normalized_rect(Rect2(drag_start, current_pos - drag_start))
		var color = Color(1, 1, 1, draw_rect_alpha)
		draw_rect(rect, color, false, 4)

func get_normalized_rect(rect: Rect2) -> Rect2:
	var position = Vector2(min(rect.position.x, rect.position.x + rect.size.x), min(rect.position.y, rect.position.y + rect.size.y))
	var size = Vector2(abs(rect.size.x), abs(rect.size.y))
	return Rect2(position, size)

func select_nodes_in_rect():
	var nodes_in_group = get_tree().get_nodes_in_group("company_zero")
	selected_nodes.clear()
	for node in nodes_in_group:
		if node is CharacterBody2D:
			var sprite = node.get_node("Sprite2D")
			if sprite:
				var node_rect = Rect2(node.global_position, Vector2(sprite.texture.get_width(), sprite.texture.get_height()))
				if selection_rect.intersects(node_rect):
					selected_nodes.append(node)
					select_node(node)

func select_node(node: Node):
	var sprite = node.get_node("Sprite2D")
	if sprite:
		print("select node is red")
		sprite.self_modulate = Color.GREEN

func deselect_all_nodes():
	for node in selected_nodes:
		var sprite = node.get_node("Sprite2D")
		if sprite:
			sprite.modulate = Color(1, 1, 1)
	selected_nodes.clear()

func start_tween():
	tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(self, "draw_rect_alpha", 0, 0.3)
	tween.finished.connect(queue_redraw)
	

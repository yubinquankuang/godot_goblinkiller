extends CharacterBody2D

# 定义兵种枚举
enum TroopType {
	FOOTMAN, # 步兵
	ARCHER, # 弓箭手
	CAVALRY, # 骑兵
	GUNNER, # 铁炮
	MOUNTED_GUNNER # 骑铁
}

# 定义等级枚举
enum TroopLevel {
	ORDINARY, # 普通士兵
	LEADER, # 组头
	CAPTAIN, # 侍大将
	LORD # 大名
}

var color_clear = Color(0,0,0,0)

# 当前兵种
var troop_type: TroopType = TroopType.FOOTMAN
# 当前等级
var troop_level: TroopLevel = TroopLevel.ORDINARY

# 不同等级对应的边框颜色
var border_colors = {
	TroopLevel.ORDINARY: color_clear,
	TroopLevel.LEADER: Color(0.75, 0.5, 0.2), # 铜色
	TroopLevel.CAPTAIN: Color(0.7, 0.7, 0.7), # 银色
	TroopLevel.LORD: Color(1, 0.84, 0) # 金色
}

# 图形大小
var size = Vector2(16, 16)
var manager = BasicNPC.new(100,122,222)

func _ready():
	set_troop_info(4,1)
	print(manager.full_name)

func _draw():
	var border_color = border_colors[troop_level]
	var pos = global_position
	var half_size = size / 2

	match troop_type:
		TroopType.FOOTMAN:
			draw_rect(Rect2(pos - half_size, size), Color.WHITE)
		TroopType.ARCHER:
			draw_rect(Rect2(pos - Vector2(size.x / 2, size.y / 4), Vector2(size.x, size.y / 2)), Color.WHITE)
		TroopType.CAVALRY:
			var points = [
				pos + Vector2(-half_size.x, half_size.y),
				pos + Vector2(half_size.x, half_size.y),
				pos + Vector2(0, -half_size.y)
			]
			draw_polygon(points, [Color.WHITE])
		TroopType.GUNNER:
			draw_circle(pos, half_size.x, Color.WHITE)
		TroopType.MOUNTED_GUNNER:
			var circle_center = pos + Vector2(0, -half_size.y / 2)
			draw_arc(circle_center, half_size.x, 0, PI, 64, Color.WHITE)

	if border_color != color_clear:
		match troop_type:
			TroopType.FOOTMAN:
				draw_rect(Rect2(pos - half_size, size), border_color, false, 2)
			TroopType.ARCHER:
				draw_rect(Rect2(pos - Vector2(size.x / 2, size.y / 4), Vector2(size.x, size.y / 2)), border_color, false, 2)
			TroopType.CAVALRY:
				var points = [
					pos + Vector2(-half_size.x, half_size.y),
					pos + Vector2(half_size.x, half_size.y),
					pos + Vector2(0, -half_size.y)
				]
				draw_polyline(points, border_color, 2)
			TroopType.GUNNER:
				draw_circle(pos, half_size.x, border_color, false, 2)
			TroopType.MOUNTED_GUNNER:
				var circle_center = pos + Vector2(0, -half_size.y / 2)
				draw_arc(circle_center, half_size.x, 0, PI, 64, border_color, false, 2)

# 设置兵种和等级的函数
func set_troop_info(new_type: TroopType, new_level: TroopLevel):
	troop_type = new_type
	troop_level = new_level
	queue_redraw()   

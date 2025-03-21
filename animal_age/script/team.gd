extends CharacterBody2D


const SPEED = 16
const JUMP_VELOCITY = -400.0

@onready var tilemap = $"../TileMapLayer2"


func _physics_process(delta):
	# Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	# 获取 TileMap 节点
	

	# 获取玩家角色的世界坐标
	var player_world_position = self.global_position

	# 将世界坐标转换为 TileMap 的图块坐标
	var tile_coordinate = tilemap.local_to_map(player_world_position)

	# 获取图块的数据
	var tile_data = tilemap.get_cell_tile_data(Vector2i(tile_coordinate.x, tile_coordinate.y))
	
	var unit_speed = SPEED
	# 检查图块数据是否存在
	if tile_data:
		# 获取自定义属性的值
		unit_speed = tile_data.get_custom_data("speed") * SPEED
		
	else:
		unit_speed = SPEED
	

	var direction_x = Input.get_axis("ui_left", "ui_right")
	if direction_x:
		velocity.x = direction_x * unit_speed
	else:
		velocity.x = move_toward(velocity.x, 0, unit_speed)
		
	var direction_y = Input.get_axis("ui_up", "ui_down")
	if direction_y:
		velocity.y = direction_y * unit_speed
	else:
		velocity.y = move_toward(velocity.y, 0, unit_speed)

	move_and_slide()



	

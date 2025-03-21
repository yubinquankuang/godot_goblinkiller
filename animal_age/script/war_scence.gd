extends Node2D

@onready var team:Node2D = $Team
@onready var map_land:TileMapLayer = $TileMapLayer
@onready var map_surface:TileMapLayer = $TileMapLayer2

var x_num = Setting.win_x / 16
var y_num = Setting.win_y / 16

func _ready():
	
	draw_map()
	

	team.position = Vector2i(80,80)

func draw_map():
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.05
	noise.fractal_lacunarity = 2.5
	
	var noise_image = noise.get_image(x_num,y_num,false,false,false)
	
	
	for y in range(y_num):
		for x in range(x_num):
			var noise_value= noise_image.get_pixel(x,y).r
			var tile_index = get_tile_index_from_noise(noise_value)
			map_land.set_cell(Vector2i(x,y),1,Vector2i(tile_index/2,0))
			map_surface.set_cell(Vector2(x,y),1,Vector2i(tile_index/2,1+tile_index/4))
	
func set_window_size(width: int, height: int):
	print("change_sie")
	DisplayServer.window_set_size(Vector2i(width, height))
	var screen_size = DisplayServer.screen_get_size()
	print(screen_size)
	DisplayServer.window_set_position(Vector2i(0,30))

func get_tile_index_from_noise(noise_value:float) ->int:
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


func _on_button_pressed():
	set_window_size(Setting.win_x,Setting.win_x)

class_name BasicNPC

# 基础属性
var health:int = 100
var soul:int = 100
var connection:int = 100

var first_name:String = "山内"
var last_name_one:String = "义"
var last_name_second:String = "治"
var nick_name:String = "鬼武藏"

# 表示身份的内容，暂时不考虑
var office_position:int = 1  # 官职：如正一位将军
var culture:int = 0          # 出身：如武藏，北信浓，近畿地区
var religion:int = 0         # 信仰：神道教 一向宗
var father:int = 0           # 父母编号：没有什么作用的屁民父母设置为0
var mother:int = 0 


var full_name:
	get:
		return first_name + last_name_one +last_name_second

# 基本方法
func _init(h,s,c):
	health = h
	soul = s
	connection = c

func my_name():
	print(full_name)

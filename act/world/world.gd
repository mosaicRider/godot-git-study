extends Node2D
@onready var camera_2d: Camera2D = $Player/Camera2D
@onready var tile_map: TileMap = $TileMap

func _ready() -> void:
	var used :=tile_map.get_used_rect()
	var tile_size:= tile_map.tile_set.tile_size
	camera_2d.limit_left = used.position.x * tile_size.x;
	camera_2d.limit_right = used.end.x * tile_size.x;
	camera_2d.limit_bottom = used.end.y * tile_size.y;
	camera_2d.limit_top = used.position.y * tile_size.y;
	# 地图太低会在跳跃时显示出来
	# 取消初始镜头与上面设置的冲突
	camera_2d.reset_smoothing();
	

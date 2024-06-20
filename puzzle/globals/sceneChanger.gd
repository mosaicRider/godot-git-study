extends CanvasLayer
@onready var color_rect: ColorRect = $ColorRect

func change_scene_to_file(path:String)->void:
	# 补间动画 黑屏变透明
	var tween := create_tween()
	tween.tween_callback(Callable(color_rect, "show"))
	tween.tween_property(color_rect,"color:a",1.0,0.2)
	var callable = Callable(get_tree(),"change_scene_to_file")
	callable.call(path)
	tween.tween_callback(callable)
	tween.tween_property(color_rect,"color:a",0.0,0.3)
	tween.tween_callback(Callable(color_rect,"hide"))

extends TextureRect


# Called when the node enters the scene tree for the first time.
func _get_drag_data(at_position):
	var data = [self,1];
	var prev = TextureRect.new();
	prev.texture = texture;
	set_drag_preview(prev);
	return data;

extends TextureRect


# Called when the node enters the scene tree for the first time.
func _can_drop_data(at_position, data):
	#if data[1] == 1:
	return true;
	return false;

func _drop_data(at_position, data):
	data[0].get_parent().remove_child(data[0]);
	add_child(data[0]);
	data[0].position.x = 0;
	data[0].position.y = 0;

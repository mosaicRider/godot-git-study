extends Interactable
class_name Teleporter

@export_file("*.tscn") var target_path :String

func _interact():
	super._interact()
	SceneChanger.change_scene_to_file(target_path)

class_name ItemPreview extends SubViewportContainer

var loaded: Node3D = null

func display(item_id: String) -> bool:
	if loaded:
		loaded.queue_free()
	if not Items.is_item_registered(item_id):
		push_warning("[ItemPreview] Item '%s' is not registered." % item_id)
		%ERROR.set_visible(true)
		return false
	var _model_path: String = Items.get_item_model_path(item_id)
	if _model_path.is_empty():
		push_warning("[ItemPreview] Item '%s' has no model to preview." % item_id)
		%ERROR.set_visible(true)
		return false
	var _model: Node3D = load("res://game/models/error.blend").instantiate()
	loaded = _model
	%PREVIEW.add_child(_model)
	%ERROR.set_visible(false)
	return true

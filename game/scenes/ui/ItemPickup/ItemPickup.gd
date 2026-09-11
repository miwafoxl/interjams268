class_name ItemPickup extends CenterContainer

const TIME_ONSCREEN_SEC: int = 5

var fade_out: bool = false

@onready var item_preview: ItemPreview = %"ITEM PREVW"
@onready var item_label: Label = %"ITEM LABEL"

func display(item_id: String, q: int = 1) -> void:
	fade_out = false
	self.set_modulate(Color(1.0, 1.0, 1.0, 0.0))
	item_preview.display(item_id)
	var _translation: String = Items.get_item_translation(item_id)
	if q > 1:
		item_label.set_text("%s x%s" % [_translation, q])
	else:
		item_label.set_text(_translation)
	await get_tree().create_timer(TIME_ONSCREEN_SEC).timeout
	fade_out = true

func invert_fade() -> void:
	fade_out = not fade_out

func _process(_delta: float) -> void:
	if fade_out:
		self.set_modulate(self.modulate.lerp(Color(1.0, 1.0, 1.0, 0.0), 0.3))
		if self.modulate.is_equal_approx(Color.TRANSPARENT):
			queue_free()
	else:
		self.set_modulate(self.modulate.lerp(Color(1.0, 1.0, 1.0, 1.0), 0.4))

class_name ViewModel extends Control

static var view_inventory: BInventory = null
static var view_input: BInput = null

var current_item_selected: int = -1

static func provide_behaviours(inventory: BInventory, input: BInput) -> void:
	view_inventory = inventory
	view_input = input

func swap_selected_item(item_id: String) -> void:
	var _model: PackedScene = load(Items.get_item_model_path(item_id))
	if _model == null:
		%ERROR.set_visible(true)
		return
	%ERROR.set_visible(false)
	%MODEL.add_child(_model.instantiate())

func _process(_delta: float) -> void:
	if view_inventory == null:
		return
	if not view_inventory.selected_item_slot == current_item_selected:
		current_item_selected = view_inventory.selected_item_slot
		var _item_id: String = view_inventory.storage.keys()[current_item_selected]
		swap_selected_item(_item_id)

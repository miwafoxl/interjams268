class_name BInventory extends Behaviour

const FALLBACK_STACK_SIZE: int = 999
const META_ITEM_STACK_SIZE: String = "stack_size"
const META_ITEM_QUANTITY: String = "quantity"

@export_category("Inventory")
@export var max_items_capacity: int = 10
@export_group("Storage")
@export var storage: Dictionary[String, Dictionary] = {} # Item ID: { Meta }
@export var quantity: Dictionary[String, int] = {} # Item ID: Amount

var selected_item_slot: int = -1 # Based on storage.keys()[index]


#region UTILITY

func has_item(item_id: String) -> bool:
	return storage.has(item_id)
	
func has_item_q(item_id: String, min_quantity: int) -> bool:
	if has_item(item_id):
		var _quantity: int = quantity.get(item_id, 0)
		return _quantity >= min_quantity
	return false

func has_items_q(items: Dictionary) -> bool: # Item ID: Min amount
	var _has: bool = true
	for _item: String in items.keys():
		var _min: int = items.get(_item, 0)
		if not quantity.get(_item, 0) >= _min:
			_has = false; break
	return _has

func can_add_item_q(item_id: String = "", add_quantity: int = 1, \
		limit: int = FALLBACK_STACK_SIZE) -> bool:
	var _storage: Dictionary = storage.get(item_id, {})
	var _storage_size: int = storage.size()
	var _stack_size: int = _storage.get(META_ITEM_STACK_SIZE, 0)
	if _stack_size + abs(add_quantity) > limit:
		return false
	if _storage_size >= max_items_capacity:
		return has_item(item_id)
	return true

#endregion UTILITY
#region INVENTORY MANAGEMENT

func merge_item_meta(item_id: String, meta: Dictionary, \
		item_exists: bool = has_item(item_id)) -> void:
	if item_exists:
		var _meta: Dictionary = storage.get(item_id, {})
		_meta.merge(meta, true)
		return
	storage.set(item_id, meta)

func add_item_q(item_id: String, meta: Dictionary = {}, add_quantity: int = 1) -> bool:
	var _item_exists: bool = has_item(item_id)
	var _quantity: int = abs(add_quantity)
	var _stack_size: int = Items.get_item_stack_size(item_id)
	if not can_add_item_q(item_id, _quantity, _stack_size):
		return false # Storage full!!
	if not _item_exists:
		quantity.set(item_id, min(_quantity, _stack_size)) 
		storage.set(item_id, meta)
		return true
	merge_item_meta(item_id, meta, _item_exists)
	return true

func remove_item_q(item_id: String, remove_quantity: int = 1) -> void:
	var _item_exists: bool = has_item(item_id)
	var _quantity: int = abs(remove_quantity)
	if _quantity == 0 or not _item_exists: return
	quantity.set(item_id, quantity.get(item_id, _quantity) - _quantity)
	var _result_quantity = quantity.get(item_id, 0)
	if _result_quantity <= 0:
		remove_item(item_id, _item_exists)

func remove_item(item_id: String, item_exists: bool = has_item(item_id)) -> bool:
	if item_exists:
		quantity.erase(item_id)
		return storage.erase(item_id)
	return false

#endregion INVENTORY MANAGEMENT
#region IMPORT/EXPORT

func export() -> Dictionary:
	var _exported: Dictionary = {}
	for _key: String in storage.keys():
		var _item_dict: Dictionary = _exported.get(_key, {})
		_item_dict.set(META_ITEM_QUANTITY, quantity.get(_key, 1))
		_exported.set(_key, _item_dict)
	return _exported

func import(exported: Dictionary, append: bool = false) -> void:
	if not append:
		storage.clear()
		quantity.clear()
	for _key: String in exported.keys():
		var _item_meta: Dictionary = exported.get(_key, {})
		var _quantity: int = _item_meta.get(META_ITEM_QUANTITY, 1)
		_item_meta.erase(META_ITEM_QUANTITY)
		_item_meta = _item_meta.merged(storage.get(_key, {}), append)
		quantity.set(_key, quantity.get(META_ITEM_QUANTITY, 0) + _quantity)
		storage.set(_key, _item_meta)

#endregion IMPORT/EXPORT

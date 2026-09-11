class_name RoamPlayUI extends Control

const ITEM_PICKUP_SCN: String = "res://game/scenes/ui/ItemPickup/ItemPickup.tscn"

@onready var item_pickup = %"VBOXC HI"
@export var player: GameObject = null

static var can_interact: bool = false
static var toast_items: Array[Dictionary] = []

static func toast_item(item_id: String, q: int = 1):
	toast_items.append({item_id: q})

func _process(_delta: float) -> void:
	if can_interact and not %"HBOX INTERACT".visible:
		%"HBOX INTERACT".set_visible(true)
	elif not can_interact and %"HBOX INTERACT".visible:
		%"HBOX INTERACT".set_visible(false)
	
	if not toast_items.is_empty():
		toast_items.pop_back.call_deferred()
		var _toast_item: Dictionary = toast_items.back()
		var _toast_scn: ItemPickup = preload(ITEM_PICKUP_SCN).instantiate()
		item_pickup.add_child(_toast_scn)
		_toast_scn.display(_toast_item.keys()[0], _toast_item.values()[0])

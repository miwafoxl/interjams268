class_name RoamPlayUI extends Control

const ITEM_PICKUP_SCN: String = "res://game/scenes/ui/ItemPickup/ItemPickup.tscn"

@onready var item_pickup = %"VBOXC HI"
@export var player: GameObject = null

@onready var tmeter_core: TemperatureMeter = %TCORE
@onready var tmeter_surface: TemperatureMeter = %TSURFACE
@onready var tmeter_gauge: TemperatureMeter  = %TGAUGE

@onready var pmeter_cooked_core: PercentageMeter = %"PCORE CK"
@onready var pmeter_cooked_surface: PercentageMeter = %"PSURF CK"
@onready var pmeter_gauge: PercentageMeter = %PGAUGE

static var can_interact: bool = false
static var toast_items: Array[Dictionary] = []

static func toast_item(item_id: String, q: int = 1):
	toast_items.append({item_id: q})

func _ready() -> void:
	pmeter_cooked_core.set_range(0.0, 1.0)
	pmeter_cooked_core.set_range(0.0, 1.0)
	pmeter_gauge.set_range(0.0, 1.0)
	tmeter_core.set_range(Cooking.cooking_temperature_range.x, Cooking.cooking_temperature_range.y)
	tmeter_surface.set_range(Cooking.cooking_temperature_range.x, Cooking.cooking_temperature_range.y)
	tmeter_gauge.set_range(Cooking.OVEN_COOKING_TEMP - 4, Cooking.OVEN_COOKING_TEMP + 4)
	Cooking.on_cook_tick(update_meter_values)
	
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

func update_meter_values() -> void:
	tmeter_core.set_temperature(Cooking.get_item_temperature(), tr("COOKING.METER.CORE"))
	tmeter_surface.set_temperature(Cooking.get_item_surface_temperature(), tr("COOKING.METER.SURFACE"))
	tmeter_gauge.set_temperature(Cooking.air_temperature, tr("COOKING.METER.OVEN"))
	pmeter_gauge.set_percentage(Cooking.get_gauge(), tr("COOKING.METER.GAUGE"))
	pmeter_cooked_core.set_percentage(Cooking.core_cooked + Cooking.core_burnt, tr("COOKING.METER.CORE_COOKED"))
	pmeter_cooked_surface.set_percentage(Cooking.surface_cooked + Cooking.surface_burnt, tr("COOKING.METER.SURF_COOKED"))

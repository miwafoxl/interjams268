class_name Cooking extends Node

const EULER: float = 2.7182818284
const ITEM_THICKNESS_M: float = 0.025 # 2.5 cm
const OVEN_COOKING_TEMP: float = 473.53 # 200 °C

@export_range(0, 1.5, 0.1) var gauge: float = 1 # 0.0 -> 2.0 MAX
static var cooking: bool = true
static var air_temperature: float = Weather.ambient_temperature
static var item_temperature: float = Weather.ambient_temperature
static var ideal_temperature: float = 423.0 + randf_range(-15, 16)

var item_diffusivity: float = 1.4 * (10 ** -7)

#region GET VALUES

## Returns the maximum value the air inside the oven can be
func get_maximum_air_temperature_k() -> float:
	return Weather.ambient_temperature + (OVEN_COOKING_TEMP * gauge)

## Returns the current temperature of the air inside the oven
func get_realtime_air_temperature_k() -> float:
	return air_temperature

## Returns current temperature of item being cooked
func get_item_temperature() -> float:
	return item_temperature

#endregion

#region COOKING  FISH  SIMULATION

var process_tick: int = 0 # Controls speed of the simulation
var cooking_tick: int = 0 # Controls the time variable in the simulation equation

func tick() -> void:
	air_temperature = lerpf(air_temperature, Weather.ambient_temperature + \
						(OVEN_COOKING_TEMP * gauge), 0.007)
	item_temperature += (air_temperature - item_temperature) * \
						(1 - EULER ** ((-(PI / (ITEM_THICKNESS_M * 2)) ** 2) * \
						(item_diffusivity * cooking_tick)))

func _process(_delta: float) -> void:
	if not cooking: return
	if process_tick >= 60:
		tick()
		cooking_tick += 1
		process_tick = 0
	process_tick += 1

#endregion COOKING  FISH  SIMULATION

func _ready() -> void:
	print("[Cooking] Ideal K: %s" % ideal_temperature)
	print("[Cooking] K * Gauge: %s" % (ideal_temperature * -gauge))

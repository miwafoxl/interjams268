class_name Cooking extends Node

# TODO: improve decay speed to be more realistic of core temperature 

const EULER: float = 2.7182818284
const ITEM_THICKNESS_M: float = 0.025 # 2.5 cm
const OVEN_COOKING_TEMP: float = 373.53 # 100 °C
const COOK_IDEAL_TEMPERATURE: float = 336.0
const COOKING_SPEED: float = 0.01 # Radians
const CONTINUOUS_HEAT_MAX: float = 6.0 # Kelvin

@export_range(0, 1.5, 0.1) var gauge: float = 0.0 # 0.0 -> 2.0 MAX Radians
static var cooking: bool = true
static var air_temperature: float = Weather.ambient_temperature
static var item_temperature: float = Weather.ambient_temperature
static var item_temperature_surface: float = Weather.ambient_temperature
#static var continuous_heat: float = 0 # Kelvin

static var cooking_temperature_range: Vector2 = Vector2(
	COOK_IDEAL_TEMPERATURE + randf_range(0, -15),
	COOK_IDEAL_TEMPERATURE + randf_range(0, 16)
	)
#static var cooking_surf_temperature_range: Vector2 = Vector2(
	#COOK_IDEAL_TEMPERATURE + randf_range(0, -15),
	#COOK_IDEAL_TEMPERATURE + randf_range(0, 16)
	#)

static var core_cooked: float = 0.0 # Radians
static var surface_cooked: float = 0.0 # Radians
static var core_burnt: float = 0.0 # Radians
static var surface_burnt: float = 0.0 # Radians

var item_diffusivity: float = 1.4 * (10.0 ** -7.0)
static var call_on_cook_tick: Array[Callable] = []

#region GET VALUES

## Returns the maximum value the air inside the oven can be
func get_maximum_air_temperature_k() -> float:
	return Weather.ambient_temperature + (OVEN_COOKING_TEMP * gauge)

## Returns the current temperature of the air inside the oven
static func get_realtime_air_temperature_k() -> float:
	return air_temperature

## Returns current core temperature of item being cooked
static func get_item_temperature() -> float:
	return item_temperature

## Returns current surface temperature of item being cooked
static func get_item_surface_temperature() -> float:
	return item_temperature_surface

## Returns current surface temperature of item being cooked
static func get_gauge() -> float:
	return clampf((air_temperature - Weather.ambient_temperature) / \
	(OVEN_COOKING_TEMP - Weather.ambient_temperature), 0.0, 1.5)

#endregion
#region CONNECT
		
static func on_cook_tick(callable: Callable) -> bool:
	if not callable in call_on_cook_tick:
		call_on_cook_tick.append(callable)
		callable.call()
		return true
	return false

#endregion
#region COOKING  FISH  SIMULATION

var process_tick: int = 0 # Controls speed of the simulation
var cooking_tick: int = 0 # Controls the time variable in the simulation equation

func tick() -> void:
	item_temperature_surface = lerpf(item_temperature_surface, air_temperature, (
							0.007 if gauge <= 0.2 else 0.01
						))
	air_temperature = lerpf(air_temperature, Weather.ambient_temperature + \
						((OVEN_COOKING_TEMP - Weather.ambient_temperature) * gauge), (
							0.01 if gauge <= 0.2 else 0.09
						))
	item_temperature += (item_temperature_surface - item_temperature) * \
						(1 - EULER ** ((-(PI / (ITEM_THICKNESS_M * 2.0)) ** 2.0) * \
						(item_diffusivity * cooking_tick)))
	#continuous_heat += lerpf(continuous_heat, CONTINUOUS_HEAT_MAX * gauge, 0.1) - continuous_heat
	if item_temperature > cooking_temperature_range.x:
		if item_temperature > cooking_temperature_range.y:
			core_burnt += COOKING_SPEED
		core_cooked += COOKING_SPEED
		core_burnt += maxf(1.0, core_cooked) - 1.0
		core_cooked = clampf(core_cooked, 0.0, 1.0)
	if item_temperature_surface > cooking_temperature_range.x:
		if item_temperature_surface > cooking_temperature_range.y:
			surface_burnt += COOKING_SPEED
		surface_cooked += COOKING_SPEED
		surface_burnt += maxf(1.0, surface_cooked) - 1.0
		surface_cooked = clampf(surface_cooked, 0.0, 1.0)
	#print("[Cooking] Core %s (Burn %s) + Surface %s (Burn %s); Continuous: %.1f K" % \
		#[core_cooked, core_burnt, surface_cooked, surface_burnt, continuous_heat * gauge])
	for _call: Callable in call_on_cook_tick:
		_call.call()

func _process(_delta: float) -> void:
	if not cooking: return
	if process_tick >= 40:
		tick()
		cooking_tick += 1
		process_tick = 0
	process_tick += 1

#endregion COOKING  FISH  SIMULATION

func _ready() -> void:
	print("[Cooking] Ideal Temp Range: %s K" % cooking_temperature_range)

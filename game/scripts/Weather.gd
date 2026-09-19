class_name Weather extends Node

const MINIMUM_TEMPERATURE: int = 279 # Kelvin
const MAXIMUM_TEMPERATURE: int = 300 # Kelvin

static var ambient_temperature: int = 288
static var ambient_temperature_c: int = 20
static var ambient_temperature_f: int = 0

static func set_temperature(kelvin: int) -> void:
	ambient_temperature = kelvin
	ambient_temperature_c = convert_kelvin_to_celcius(kelvin)
	ambient_temperature_f = convert_kelvin_to_fahrenheint(kelvin)
	print("[Weather] Set ambient temperature to %s °C" % ambient_temperature_c)

static func convert_kelvin_to_celcius(kelvin: int) -> int:
	return kelvin - 273

static func convert_kelvin_to_celcius_f(kelvin: float) -> float:
	return kelvin - 273.15

static func convert_kelvin_to_fahrenheint(kelvin: int) -> int:
	return ceili(((kelvin - 273) * 1.8) + 32)

func _ready() -> void:
	set_temperature(MINIMUM_TEMPERATURE + (rand_from_seed(Random.current_seed)[0] % \
			(MAXIMUM_TEMPERATURE - MINIMUM_TEMPERATURE)))

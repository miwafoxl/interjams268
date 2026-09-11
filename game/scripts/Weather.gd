class_name Weather extends Node

const MINIMUM_TEMPERATURE: int = 279 # Kelvin
const MAXIMUM_TEMPERATURE: int = 300 # Kelvin
const MINIMUM_WIND: int = 0
const MAXIMUM_WIND: int = 40
const HEAT_LOSS_COEFFECIENT: float = 0.0886
const HEAT_GAIN_COEFFECIENT: float = -0.288

static var weather_seed: int = floor(Time.get_unix_time_from_system())
static var ambient_temperature: int = 279
static var ambient_temperature_c: int = 20
static var ambient_temperature_f: int = 0
static var wind_kmph: int = 0
static var wind_mph: int = 0

static func set_temperature(kelvin: int) -> void:
	ambient_temperature = kelvin
	ambient_temperature_c = kelvin - 273
	ambient_temperature_f = ceili((ambient_temperature_c * 1.8) + 32)
	print("[Weather] Set ambient temperature to %s °C" % ambient_temperature_c)

static func set_wind(kmph: int) -> void:
	wind_kmph = kmph
	wind_mph = ceili(kmph / 1.603)
	print("[Weather] Set wind speed to %skmph" % wind_kmph)

static func calculate_heat_loss(temperature_k: int, ambient: int = ambient_temperature) -> int:
	return round(HEAT_LOSS_COEFFECIENT * (ambient - temperature_k))

static func calculate_heat_gain(temperature_k: int, ambient: int = ambient_temperature) -> int:
	return round(HEAT_GAIN_COEFFECIENT * (ambient - temperature_k))

func _ready() -> void:
	set_temperature(MINIMUM_TEMPERATURE + (rand_from_seed(weather_seed)[0] % \
			(MAXIMUM_TEMPERATURE - MINIMUM_TEMPERATURE)))
	set_wind(MINIMUM_WIND + (rand_from_seed(weather_seed)[0] % \
			(MAXIMUM_WIND - MINIMUM_WIND)))

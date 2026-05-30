extends Node

## Deterministic weather system driven by coordinates + season + time.
## Weather is a pure function: same inputs always produce the same output.
## No random simulation — smooth transitions as the ship sails.

## Weather data returned by get_weather().
class WeatherData:
	var wind_direction: Vector2 = Vector2(1.0, 0.0)
	var wind_speed: float = 0.3          # 0..1 normalized
	var wave_intensity: float = 0.5      # 0..1, scales wave amplitudes
	var fog_density: float = 0.003       # matches Environment.fog_density
	var precipitation: float = 0.0       # 0..1
	var sky_tint: Color = Color(1, 1, 1) # multiplicative tint for sky colors

## Base wave intensity for each climate (calm tropics → stormy north).
const _CLIMATE_WAVE_BASE := {
	BiomeData.Climate.NORTH: 0.7,
	BiomeData.Climate.TEMPERATE: 0.5,
	BiomeData.Climate.TROPICS: 0.3,
}

## Base fog density for each climate.
const _CLIMATE_FOG_BASE := {
	BiomeData.Climate.NORTH: 0.006,
	BiomeData.Climate.TEMPERATE: 0.003,
	BiomeData.Climate.TROPICS: 0.004,
}

## Base wind speed for each climate.
const _CLIMATE_WIND_BASE := {
	BiomeData.Climate.NORTH: 0.6,
	BiomeData.Climate.TEMPERATE: 0.35,
	BiomeData.Climate.TROPICS: 0.25,
}

## Season modifiers to wave intensity (Phase 7 will provide TimeManager).
## Until then, defaults to SUMMER.
var _season_wave_modifier: float = 1.0
var _season_fog_modifier: float = 1.0

## Cached weather for the current frame (updated in _process).
var _current_weather: WeatherData


func _ready() -> void:
	_current_weather = WeatherData.new()


func _process(_delta: float) -> void:
	# Find the ship to track its position
	var ship: Node3D = _get_ship()
	if not ship:
		return

	_current_weather = get_weather(ship.global_position)
	WaveCalculator.set_weather_scale(_current_weather.wave_intensity, _current_weather.wind_direction)


## Get deterministic weather at a world position.
## Currently uses latitude only; longitude + season + time add variation later.
func get_weather(pos: Vector3) -> WeatherData:
	var w := WeatherData.new()
	var climate: int = BiomeManager.get_climate(pos)
	var lat_norm: float = WorldMap.latitude_normalized(pos)  # -1..1

	# Wave intensity: base per climate + latitude variation
	w.wave_intensity = _CLIMATE_WAVE_BASE.get(climate, 0.5) * _season_wave_modifier
	# More extreme at higher |latitude|
	w.wave_intensity += absf(lat_norm) * 0.15
	w.wave_intensity = clampf(w.wave_intensity, 0.1, 1.0)

	# Wind: primarily from west (positive X) with latitude-dependent direction
	var wind_angle: float = lat_norm * 0.5  # shifts direction with latitude
	w.wind_direction = Vector2(cos(wind_angle), sin(wind_angle)).normalized()
	w.wind_speed = _CLIMATE_WIND_BASE.get(climate, 0.35) * _season_wave_modifier

	# Fog: base per climate + seasonal modifier
	w.fog_density = _CLIMATE_FOG_BASE.get(climate, 0.003) * _season_fog_modifier

	# Precipitation: higher in north and during storms
	w.precipitation = clampf(absf(lat_norm) - 0.5, 0.0, 0.5) * 2.0

	# Sky tint: north = cooler, tropics = warmer
	match climate:
		BiomeData.Climate.NORTH:
			w.sky_tint = Color(0.85, 0.88, 0.95)
		BiomeData.Climate.TEMPERATE:
			w.sky_tint = Color(1.0, 1.0, 1.0)
		BiomeData.Climate.TROPICS:
			w.sky_tint = Color(1.0, 0.97, 0.92)

	return w


## Get the current cached weather (updated each frame).
func current_weather() -> WeatherData:
	return _current_weather


## Set season modifiers (called by TimeManager in Phase 7).
## wave_mod: 1.0 = normal, >1 = stormier, <1 = calmer
## fog_mod: 1.0 = normal, >1 = foggier
func set_season_modifiers(wave_mod: float, fog_mod: float) -> void:
	_season_wave_modifier = wave_mod
	_season_fog_modifier = fog_mod


## Find the ship node in the scene tree.
func _get_ship() -> Node3D:
	var tree: SceneTree = get_tree()
	if not tree:
		return null
	var current: Node = tree.current_scene
	if not current:
		return null
	# Ship is a direct child of the Ocean scene
	var ship: Node = current.get_node_or_null("Ship")
	if ship is Node3D:
		return ship
	# Fallback: search for RigidBody3D in "ship" group
	var ships: Array[Node] = tree.get_nodes_in_group("ship")
	if ships.size() > 0 and ships[0] is Node3D:
		return ships[0] as Node3D
	return null

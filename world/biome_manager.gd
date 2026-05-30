extends Node

## Determines biome from world coordinates via latitude.
## Climate belts: North (lat > +30°), Temperate (-30° to +30°), Tropics (lat < -30°).
## Longitude can add sub-biome variation in the future.

## Latitude thresholds for climate belt boundaries (degrees).
@export var north_threshold: float = 30.0
@export var tropics_threshold: float = -30.0


## Get the climate enum for a world position.
func get_climate(pos: Vector3) -> BiomeData.Climate:
	var lat: float = WorldMap.get_latitude(pos)
	if lat > north_threshold:
		return BiomeData.Climate.NORTH
	elif lat < tropics_threshold:
		return BiomeData.Climate.TROPICS
	else:
		return BiomeData.Climate.TEMPERATE


## Get full biome data for a world position.
func get_biome(pos: Vector3) -> BiomeData:
	return BiomeData.from_climate(get_climate(pos))


## Get climate name as string (for UI/debug).
func get_climate_name(pos: Vector3) -> String:
	match get_climate(pos):
		BiomeData.Climate.NORTH: return "North"
		BiomeData.Climate.TEMPERATE: return "Temperate"
		BiomeData.Climate.TROPICS: return "Tropics"
		_: return "Unknown"


## Smooth blend factor for climate transitions.
## Returns 0.0 at center of a belt, 1.0 at the boundary.
## Useful for gradually blending visual parameters between belts.
func get_transition_factor(pos: Vector3) -> float:
	var lat: float = WorldMap.get_latitude(pos)
	var climate := get_climate(pos)
	var half_width: float = (north_threshold - tropics_threshold) / 2.0
	var center: float = 0.0

	match climate:
		BiomeData.Climate.NORTH:
			center = (north_threshold + WorldMap.max_latitude) / 2.0
			half_width = (WorldMap.max_latitude - north_threshold) / 2.0
		BiomeData.Climate.TEMPERATE:
			center = 0.0
			half_width = (north_threshold - tropics_threshold) / 2.0
		BiomeData.Climate.TROPICS:
			center = (tropics_threshold - WorldMap.max_latitude) / 2.0
			half_width = (WorldMap.max_latitude - absf(tropics_threshold)) / 2.0

	if half_width <= 0.0:
		return 0.0
	return clampf(absf(lat - center) / half_width, 0.0, 1.0)

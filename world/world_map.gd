extends Node

## Handles sphere→plane projection for the game world.
## Maps flat game-world coordinates to latitude/longitude on a planet.
## The planet has no accessible poles — latitude is clamped.

## World units per degree of latitude at the equator.
## At this scale, ~1 degree ≈ 111 km (real Earth), but gameplay scale is compressed.
@export var world_units_per_degree: float = 100.0

## Maximum absolute latitude (degrees). Beyond this, poles are unreachable.
@export var max_latitude: float = 70.0

## Longitude wraps around (full sphere). Total degrees = 360.
const LONGITUDE_RANGE := 360.0


## Convert world position to (latitude, longitude) in degrees.
## Latitude comes from Z-axis (north = negative Z, south = positive Z).
## Longitude comes from X-axis, wrapping around the planet.
func world_to_latlong(pos: Vector3) -> Vector2:
	var lat := -pos.z / world_units_per_degree
	var lon := fmod(pos.x / world_units_per_degree, LONGITUDE_RANGE)
	if lon < -LONGITUDE_RANGE / 2.0:
		lon += LONGITUDE_RANGE
	elif lon > LONGITUDE_RANGE / 2.0:
		lon -= LONGITUDE_RANGE
	lat = clampf(lat, -max_latitude, max_latitude)
	return Vector2(lat, lon)


## Convenience: get latitude only from world position.
func get_latitude(pos: Vector3) -> float:
	return clampf(-pos.z / world_units_per_degree, -max_latitude, max_latitude)


## Convenience: get longitude only from world position.
func get_longitude(pos: Vector3) -> float:
	var lon: float = fmod(pos.x / world_units_per_degree, LONGITUDE_RANGE)
	if lon < -LONGITUDE_RANGE / 2.0:
		lon += LONGITUDE_RANGE
	elif lon > LONGITUDE_RANGE / 2.0:
		lon -= LONGITUDE_RANGE
	return lon


## Convert latitude to a normalized value [-1, 1] where -1 = max north, +1 = max south.
func latitude_normalized(pos: Vector3) -> float:
	return get_latitude(pos) / max_latitude


## Distance in world units between two lat/long points (approximate, for nearby points).
func latlong_distance(a: Vector2, b: Vector2) -> float:
	var dlat: float = (b.x - a.x) * world_units_per_degree
	var dlon: float = (b.y - a.y) * world_units_per_degree * cos(deg_to_rad((a.x + b.x) / 2.0))
	return Vector2(dlat, dlon).length()

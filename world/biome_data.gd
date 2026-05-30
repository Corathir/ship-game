class_name BiomeData
extends Resource

## Data container for a biome region. Determined by latitude/longitude.

enum Climate { NORTH, TEMPERATE, TROPICS }

@export var climate: Climate = Climate.TEMPERATE
@export var base_temperature: float = 20.0          # Celsius baseline
@export var available_resources: PackedStringArray = []  # e.g. ["planks", "tar"]
@export var dangers: PackedStringArray = []              # e.g. ["frostbite", "ice"]
@export var water_color_tint: Color = Color(0, 0, 0, 0) # additive tint for ocean color


static func from_climate(c: Climate) -> BiomeData:
	var data := BiomeData.new()
	data.climate = c
	match c:
		Climate.NORTH:
			data.base_temperature = -5.0
			data.available_resources = PackedStringArray(["tar", "seals", "cod"])
			data.dangers = PackedStringArray(["frostbite", "ice"])
			data.water_color_tint = Color(0.0, 0.05, 0.1, 1.0)  # darker, bluer
		Climate.TEMPERATE:
			data.base_temperature = 15.0
			data.available_resources = PackedStringArray(["planks", "apples", "beer"])
			data.dangers = PackedStringArray([])
			data.water_color_tint = Color(0, 0, 0, 0)  # no tint (default)
		Climate.TROPICS:
			data.base_temperature = 30.0
			data.available_resources = PackedStringArray(["rope", "fruit", "spices", "rum"])
			data.dangers = PackedStringArray(["fever"])
			data.water_color_tint = Color(0.0, 0.05, -0.05, 1.0)  # slightly greener
	return data

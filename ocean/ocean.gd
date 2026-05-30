extends Node3D

@onready var world_env: WorldEnvironment = $WorldEnvironment
@onready var sky_mat: ProceduralSkyMaterial = world_env.environment.sky.sky_material


func _ready() -> void:
	var water_lod := $WaterLOD
	var mat: ShaderMaterial = water_lod.water_material

	if mat:
		WaveCalculator.register_material(mat)
	else:
		DebugLogger.warn("Ocean: water_material not set on WaterLOD", self)


func _process(_delta: float) -> void:
	if not WeatherManager or not world_env:
		return

	var weather: WeatherManager.WeatherData = WeatherManager.current_weather()
	if not weather:
		return

	# Apply fog density from weather
	world_env.environment.fog_density = weather.fog_density

	# Apply sky tint to ProceduralSkyMaterial colors
	sky_mat.sky_top_color = Color(0.2901961, 0.5647059, 0.78431374) * weather.sky_tint
	sky_mat.sky_horizon_color = Color(0.72156864, 0.83137256, 0.9098039) * weather.sky_tint

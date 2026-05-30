extends Node3D


func _ready() -> void:
	var water_lod := $WaterLOD
	var mat: ShaderMaterial = water_lod.water_material

	if mat:
		WaveCalculator.register_material(mat)
	else:
		DebugLogger.warn("Ocean: water_material not set on WaterLOD", self)

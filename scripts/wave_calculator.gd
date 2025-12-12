# wave_calculator.gd
extends Node

# Параметры волн — единственный источник истины
var amplitude1 := 0.5
var amplitude2 := 0.3
var frequency1 := 0.5
var frequency2 := 0.8
var speed := 1.0

# Ссылка на материал воды
var _water_material: ShaderMaterial

## Регистрирует материал воды для синхронизации параметров
func register_material(mat: ShaderMaterial) -> void:
    _water_material = mat
    _sync_to_shader()

## Синхронизирует параметры с шейдером
func _sync_to_shader() -> void:
    if _water_material:
        _water_material.set_shader_parameter("amplitude1", amplitude1)
        _water_material.set_shader_parameter("amplitude2", amplitude2)
        _water_material.set_shader_parameter("frequency1", frequency1)
        _water_material.set_shader_parameter("frequency2", frequency2)
        _water_material.set_shader_parameter("speed", speed)

## Устанавливает параметр и синхронизирует с шейдером
func set_param(param_name: String, value: float) -> void:
    match param_name:
        "amplitude1": amplitude1 = value
        "amplitude2": amplitude2 = value
        "frequency1": frequency1 = value
        "frequency2": frequency2 = value
        "speed": speed = value
    _sync_to_shader()

## Возвращает высоту воды в точке (x, z)
func get_height(x: float, z: float) -> float:
    var t := Time.get_ticks_msec() / 1000.0
    var wave1 := sin(x * frequency1 + t * speed) * amplitude1
    var wave2 := sin(z * frequency2 + t * speed * 1.3) * amplitude2
    var wave3 := sin(x * 1.5 + z * 0.8 + t * speed * 2.0) * 0.15
    var wave4 := sin(x * 0.6 - z * 1.2 + t * speed * 1.7) * 0.1
    return wave1 + wave2 + wave3 + wave4

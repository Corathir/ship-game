extends Node

## Single source of truth for wave parameters.
## Feeds identical Gerstner math to both the shader (via uniforms)
## and physics (via get_height / get_displacement / get_normal).
##
## Shader counterpart: ocean/gerstner.glsl (reference doc)
## ocean/water.gdshader (vertex shader loop)
## Any changes to the Gerstner formula MUST be mirrored in all three files.

const GRAVITY := 9.81
const MAX_WAVES := 8   # Must match MAX_WAVES in water.gdshader and gerstner.glsl
const STRIDE := 6      # Must match STRIDE in water.gdshader and gerstner.glsl


class WaveParams:
    var direction: Vector2
    var amplitude: float
    var steepness: float
    var wavelength: float
    ## k = 2π / wavelength (wave number)
    var k: float
    ## ω = sqrt(g · k) (angular frequency, deep water dispersion)
    var omega: float

    func _init(dir: Vector2, amp: float, wl: float, steep: float) -> void:
        direction = dir.normalized()
        amplitude = amp
        wavelength = wl
        steepness = clampf(steep, 0.0, 1.0)
        k = TAU / wavelength
        omega = sqrt(GRAVITY * k)


var waves: Array[WaveParams] = []
var _water_material: ShaderMaterial


func _ready() -> void:
    _build_default_waves()


# ============================================================================
# CONFIGURATION
# ============================================================================

func _build_default_waves() -> void:
    waves.clear()
    # Primary swell — long, slow, dominant direction
    waves.append(WaveParams.new(Vector2(1.0, 0.3), 0.55, 40.0, 0.6))
    waves.append(WaveParams.new(Vector2(0.8, 0.6), 0.35, 28.0, 0.55))
    # Secondary swell — crossing angle
    waves.append(WaveParams.new(Vector2(0.3, 1.0), 0.25, 20.0, 0.5))
    # Medium chop
    waves.append(WaveParams.new(Vector2(-0.4, 0.9), 0.15, 12.0, 0.45))
    waves.append(WaveParams.new(Vector2(0.7, -0.5), 0.10, 8.0, 0.4))
    # Fine detail
    waves.append(WaveParams.new(Vector2(-0.6, -0.8), 0.06, 5.0, 0.35))
    _sync_to_shader()


## Replace entire wave set (e.g. for storm transitions).
func set_waves(new_waves: Array[WaveParams]) -> void:
    if new_waves.size() > MAX_WAVES:
        DebugLogger.warn("WaveCalculator: wave set truncated to %d (MAX_WAVES)" % MAX_WAVES, self)
    waves = new_waves
    _sync_to_shader()


# ============================================================================
# SHADER SYNCHRONIZATION
# ============================================================================

func register_material(mat: ShaderMaterial) -> void:
    if not mat:
        DebugLogger.error("WaveCalculator: register_material called with null", self)
        return
    _water_material = mat
    _sync_to_shader()
    _validate_shader_sync()


## Verify shader constants match GDScript — catches drift between the three files.
func _validate_shader_sync() -> void:
    if not _water_material:
        return

    var shader: Shader = _water_material.shader
    if not shader:
        DebugLogger.warn("WaveCalculator: material has no shader, cannot validate sync", self)
        return

    var code: String = shader.code
    if code.is_empty():
        return

    # Check that the shader's wave_data array size matches MAX_WAVES * STRIDE
    var expected_size := MAX_WAVES * STRIDE
    var regex := RegEx.new()
    regex.compile("uniform\\s+float\\s+wave_data\\[(\\d+)\\]")
    var result := regex.search(code)
    if result:
        var shader_size := int(result.get_string(1))
        if shader_size != expected_size:
            DebugLogger.error(
                "WaveCalculator: shader wave_data[%d] != GDScript MAX_WAVES*STRIDE=%d. "
                % [shader_size, expected_size] + "Update water.gdshader or wave_calculator.gd to match.",
                self
            )
    else:
        DebugLogger.debug("WaveCalculator: could not find wave_data uniform in shader code", self)


func _sync_to_shader() -> void:
    if not _water_material:
        return

    var data := PackedFloat32Array()
    data.resize(MAX_WAVES * STRIDE)
    data.fill(0.0)

    for i in mini(waves.size(), MAX_WAVES):
        var w := waves[i]
        var idx := i * STRIDE
        data[idx] = w.direction.x
        data[idx + 1] = w.direction.y
        data[idx + 2] = w.amplitude
        data[idx + 3] = w.steepness
        data[idx + 4] = w.k
        data[idx + 5] = w.omega

    _water_material.set_shader_parameter("wave_count", mini(waves.size(), MAX_WAVES))
    _water_material.set_shader_parameter("wave_data", data)


# ============================================================================
# PHYSICS QUERIES — same math as gerstner.glsl gerstner_evaluate()
# ============================================================================

func _get_time() -> float:
    return Time.get_ticks_msec() / 1000.0


## Full 3D Gerstner displacement at world position (x, z).
## Returns Vector3 offset to add to the undisplaced position.
## Mirrors: gerstner.glsl → r.displacement, water.gdshader vertex loop
func get_displacement(x: float, z: float) -> Vector3:
    var t := _get_time()
    var disp := Vector3.ZERO

    for w in waves:
        # θ = k · dot(D, P.xz) + ω · t
        var phase := w.k * (w.direction.x * x + w.direction.y * z) + w.omega * t
        var s := sin(phase)
        var c := cos(phase)

        # Gerstner: horizontal shift toward crests, vertical sinusoid
        disp.x -= w.direction.x * w.steepness * w.amplitude * s
        disp.z -= w.direction.y * w.steepness * w.amplitude * s
        disp.y += w.amplitude * c

    return disp


## Water surface height at world position (x, z).
## Y component of the Gerstner displacement — optimized (skips X/Z).
## Mirrors: gerstner.glsl → r.displacement.y, water.gdshader vertex loop
func get_height(x: float, z: float) -> float:
    var t := _get_time()
    var height := 0.0

    for w in waves:
        var phase := w.k * (w.direction.x * x + w.direction.y * z) + w.omega * t
        height += w.amplitude * cos(phase)

    return height


## Analytical surface normal at world position (x, z).
## Same formula as gerstner.glsl → r.normal, water.gdshader vertex loop
func get_normal(x: float, z: float) -> Vector3:
    var t := _get_time()
    var nx := 0.0
    var ny := 1.0
    var nz := 0.0

    for w in waves:
        var phase := w.k * (w.direction.x * x + w.direction.y * z) + w.omega * t
        var s := sin(phase)
        var c := cos(phase)

        # Gerstner analytical normal:
        #   N.x = -Σ D.x · k · A · cos(θ)
        #   N.y =  1 - Σ Q · k · A · sin(θ)
        #   N.z = -Σ D.y · k · A · cos(θ)
        var ka := w.k * w.amplitude
        nx -= w.direction.x * ka * c
        ny -= w.steepness * ka * s
        nz -= w.direction.y * ka * c

    return Vector3(nx, ny, nz).normalized()


## Full displaced world position from undisplaced (x, z).
## Use for probe points that need the exact surface point.
func get_surface_point(x: float, z: float) -> Vector3:
    var disp := get_displacement(x, z)
    return Vector3(x + disp.x, disp.y, z + disp.z)


## Foam intensity at world position (x, z).
## Based on Jacobian — 0 = no foam, 1 = max foam.
## Mirrors: gerstner.glsl → r.jacobian, water.gdshader foam formula
func get_foam(x: float, z: float, threshold: float = 0.0) -> float:
    var t := _get_time()
    # J = 1 - Σ Q · k · A · cos(θ)
    var jacobian := 1.0

    for w in waves:
        var phase := w.k * (w.direction.x * x + w.direction.y * z) + w.omega * t
        var c := cos(phase)
        jacobian -= w.steepness * w.k * w.amplitude * c

    return clampf(-jacobian + threshold, 0.0, 1.0)

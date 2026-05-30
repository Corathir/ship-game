---
paths: ["ocean/**/*.gdshader", "ocean/**/*.glsl", "**/*.gdshader"]
---

# Water Shader Project Notes

## Current Shader (water.gdshader)

- Inline Gerstner vertex displacement (loop matches `gerstner.glsl` reference doc)
- PBR with metallic/roughness control
- Deep-to-surface color gradient + SSS (subsurface scattering)
- Jacobian-based foam at wave crests
- Optional normal map detail (two scrolling layers)
- Optional refraction with depth fade

## Gerstner Formula (gerstner.glsl)

The canonical Gerstner formula is documented in `ocean/gerstner.glsl`.
Any changes to wave math MUST be mirrored in:
  1. `ocean/gerstner.glsl` (reference)
  2. `ocean/water.gdshader` (vertex shader loop)
  3. `ocean/wave_calculator.gd` (GDScript physics queries)
`WaveCalculator._validate_shader_sync()` checks for shader↔GDScript drift at runtime.

## Wave Uniforms (fed from WaveCalculator)

- `wave_count`: int (1–8) — number of active waves
- `wave_data`: float[48] — packed [dir_x, dir_y, amplitude, steepness, k, omega] per wave

## Modifying Waves

1. Edit wave definitions in `wave_calculator.gd::_build_default_waves()`
2. WaveCalculator syncs to shader automatically via `_sync_to_shader()`
3. Never edit wave uniforms directly in the ShaderMaterial — WaveCalculator owns them

## Performance

- Water shader runs on large LOD mesh — keep vertex shader efficient
- Gerstner loop is bounded by `GERSTNER_MAX_WAVES` (8) — constant, GPU-friendly
- Minimize fragment shader texture samples
- Use `render_mode` for optimal culling and blending
- Avoid branching in fragment shader — use `mix`/`smoothstep` instead

## Uniform Naming

- `snake_case`, prefix related params: `wave_amplitude`, `wave_frequency`
- Use `hint_range` for numeric uniforms, `source_color` for colors
- Group related uniforms: `group_uniforms WaveSettings;`

## GLSL Reference File

- `ocean/gerstner.glsl` is a reference document, NOT included by the shader
- Godot does not support `#include` in `.gdshader` files
- Keep shared math documented in `gerstner.glsl` to avoid shader↔GDScript drift
- `WaveCalculator._validate_shader_sync()` verifies shader array size matches at runtime

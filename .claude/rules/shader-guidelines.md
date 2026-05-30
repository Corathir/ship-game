---
paths: ["ocean/**/*.gdshader", "**/*.gdshader"]
---

# Water Shader Project Notes

## Current Shader (water.gdshader)

- Vertex displacement for wave geometry
- Multiple wave frequencies combined
- Configurable via uniforms: `amplitude1`, `amplitude2`, `frequency1`, `frequency2`, `speed`
- PBR with metallic/roughness control
- Deep-to-surface color gradient (`color_deep` → `color_surface`)

## Modifying Waves

1. `amplitude1/2` → wave height
2. `frequency1/2` → wave density
3. `speed` → animation speed
4. Add directional waves for wind effects
5. Normal mapping for surface detail without geometry cost

## Performance

- Water shader runs on large LOD mesh — keep vertex shader efficient
- Minimize fragment shader texture samples
- Use `render_mode` for optimal culling and blending
- Avoid branching in fragment shader — use `mix`/`smoothstep` instead

## Uniform Naming

- `snake_case`, prefix related params: `wave_amplitude`, `wave_frequency`
- Use `hint_range` for numeric uniforms, `source_color` for colors
- Group related uniforms: `group_uniforms WaveSettings;`

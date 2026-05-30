---
paths: ["ocean/**/*.gdshader", "**/*.gdshader"]
---

# Godot Shader Guidelines

## General Shader Principles

### Shader Types
- **Spatial**: 3D materials (most common for this project)
- **Canvas Item**: 2D materials
- **Particles**: Particle system materials
- **Sky**: Sky and environment shaders
- **Fog**: Volumetric fog shaders

### Shader Structure
```glsl
shader_type spatial;  // or canvas_item, particles, sky, fog

// Render modes
render_mode blend_mix, depth_draw_opaque, cull_back;

// Uniforms (exposed to material inspector)
uniform float amplitude : hint_range(0.0, 10.0) = 1.0;
uniform vec3 color : source_color = vec3(1.0, 1.0, 1.0);
uniform sampler2D texture_albedo : source_color, filter_linear;

// Varyings (pass data between vertex and fragment)
varying vec3 world_pos;

// Vertex shader
void vertex() {
    // Modify vertex position, normals, etc.
}

// Fragment shader
void fragment() {
    // Calculate final pixel color
}
```

## Uniform Best Practices

### Naming Conventions
- Use `snake_case` for uniform names
- Prefix related parameters: `wave_amplitude`, `wave_frequency`
- Use descriptive names: `color_deep` instead of `col1`

### Hints and Annotations
```glsl
// Ranges
uniform float speed : hint_range(0.0, 100.0, 0.1) = 1.0;

// Colors
uniform vec3 water_color : source_color = vec3(0.0, 0.4, 0.8);

// Textures
uniform sampler2D albedo_tex : source_color, filter_linear_mipmap;
uniform sampler2D normal_tex : hint_normal, filter_linear;
uniform sampler2D height_tex : hint_default_white;

// Groups (organize in inspector)
group_uniforms WaveSettings;
uniform float amplitude1;
uniform float frequency1;
group_uniforms;
```

### Texture Filtering
- `filter_linear`: Smooth interpolation
- `filter_nearest`: Pixelated/sharp
- `filter_linear_mipmap`: Smooth with mipmaps (best for 3D)

## Vertex Shader Guidelines

### Position Manipulation
```glsl
void vertex() {
    // Get world position for wave calculation
    vec3 world_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

    // Calculate wave displacement
    float wave = sin(world_vertex.x * frequency + TIME * speed) * amplitude;

    // Apply to vertex position (local space)
    VERTEX.y += wave;

    // Pass to fragment shader if needed
    world_pos = world_vertex;
}
```

### Normal Calculation
```glsl
void vertex() {
    // For procedural geometry, recalculate normals
    vec3 tangent_x = vec3(1.0, derivative_y_wrt_x, 0.0);
    vec3 tangent_z = vec3(0.0, derivative_y_wrt_z, 1.0);
    NORMAL = normalize(cross(tangent_z, tangent_x));
}
```

## Fragment Shader Guidelines

### PBR Materials
```glsl
void fragment() {
    // Albedo (base color)
    ALBEDO = color_surface.rgb;

    // Metallic (0.0 = dielectric, 1.0 = metal)
    METALLIC = metallic;

    // Roughness (0.0 = smooth/glossy, 1.0 = rough/matte)
    ROUGHNESS = roughness;

    // Specular (reflectivity for dielectrics)
    SPECULAR = 0.5;

    // Normal mapping
    NORMAL_MAP = texture(normal_texture, UV).rgb;

    // Emission (self-illumination)
    EMISSION = vec3(0.0);

    // Alpha/transparency
    ALPHA = 1.0;
}
```

### Color Blending
```glsl
// Lerp between two colors based on depth/height
vec3 water_color = mix(color_deep, color_surface, depth_factor);

// Smoothstep for smooth transitions
float factor = smoothstep(0.0, 1.0, input_value);

// Clamp values
float clamped = clamp(value, 0.0, 1.0);
```

## Wave Calculations

### Multi-Wave Synthesis
```glsl
float calculate_wave(vec3 pos, float time) {
    // Primary wave
    float wave1 = sin(pos.x * frequency1 + time * speed) * amplitude1;

    // Secondary wave (different direction)
    float wave2 = sin(pos.z * frequency2 + time * speed * 0.8) * amplitude2;

    // Combine waves
    return wave1 + wave2;
}
```

### Gerstner Waves (More Realistic)
```glsl
vec3 gerstner_wave(vec3 pos, vec2 direction, float steepness, float wavelength, float time) {
    float k = 2.0 * PI / wavelength;
    float c = sqrt(9.8 / k);
    vec2 d = normalize(direction);
    float f = k * (dot(d, pos.xz) - c * time);
    float a = steepness / k;

    return vec3(
        d.x * a * cos(f),
        a * sin(f),
        d.y * a * cos(f)
    );
}
```

## Performance Optimization

### Minimize Texture Lookups
```glsl
// Bad: Multiple lookups
vec3 color1 = texture(tex, UV).rgb;
float alpha1 = texture(tex, UV).a;

// Good: Single lookup
vec4 tex_sample = texture(tex, UV);
vec3 color1 = tex_sample.rgb;
float alpha1 = tex_sample.a;
```

### Avoid Branching
```glsl
// Bad: Conditional branching in fragment shader
if (depth > 0.5) {
    ALBEDO = color_deep;
} else {
    ALBEDO = color_shallow;
}

// Good: Use mix/lerp
float factor = step(0.5, depth);
ALBEDO = mix(color_shallow, color_deep, factor);
// Or even better:
ALBEDO = mix(color_shallow, color_deep, smoothstep(0.0, 1.0, depth));
```

### Precalculate in Vertex Shader
```glsl
// Move expensive calculations to vertex shader when possible
varying float wave_height;

void vertex() {
    wave_height = calculate_complex_wave(VERTEX);
}

void fragment() {
    // Use precalculated value
    ALBEDO = mix(color_deep, color_surface, wave_height);
}
```

## Time-Based Animation

### Using TIME Uniform
```glsl
uniform float speed = 1.0;

void vertex() {
    // Animate waves over time
    float wave = sin(VERTEX.x * 2.0 + TIME * speed);
    VERTEX.y += wave;
}
```

### Multiple Time Scales
```glsl
// Fast ripples
float ripple = sin(pos.x * 10.0 + TIME * 5.0) * 0.1;

// Slow swells
float swell = sin(pos.x * 0.5 + TIME * 0.3) * 2.0;

float total = ripple + swell;
```

## Water-Specific Techniques

### Depth-Based Color
```glsl
uniform vec3 color_deep : source_color;
uniform vec3 color_surface : source_color;

void fragment() {
    // Get depth from depth texture
    float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r;
    float linear_depth = linearize_depth(depth);

    // Blend colors based on depth
    float depth_factor = clamp(linear_depth / 10.0, 0.0, 1.0);
    ALBEDO = mix(color_surface, color_deep, depth_factor);
}
```

### Foam/Edge Effects
```glsl
void fragment() {
    float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r;
    float scene_depth = linearize_depth(depth);
    float pixel_depth = linearize_depth(FRAGCOORD.z);
    float depth_diff = scene_depth - pixel_depth;

    // Foam at shallow areas
    float foam = 1.0 - smoothstep(0.0, 0.5, depth_diff);
    ALBEDO = mix(water_color, foam_color, foam);
}
```

### Normal Perturbation
```glsl
uniform sampler2D normal_map;
uniform float normal_strength = 1.0;

void fragment() {
    // Sample normal map with animated UV
    vec2 uv1 = UV + TIME * 0.05;
    vec2 uv2 = UV * 0.7 - TIME * 0.03;

    vec3 normal1 = texture(normal_map, uv1).rgb * 2.0 - 1.0;
    vec3 normal2 = texture(normal_map, uv2).rgb * 2.0 - 1.0;

    // Combine normals
    vec3 combined = normalize(normal1 + normal2);
    NORMAL_MAP = combined * normal_strength;
}
```

## Built-in Variables Reference

### Vertex Shader
- `VERTEX`: Vertex position (local space)
- `NORMAL`: Vertex normal
- `UV`, `UV2`: Texture coordinates
- `COLOR`: Vertex color
- `MODEL_MATRIX`: Model transform matrix
- `VIEW_MATRIX`: View (camera) matrix
- `PROJECTION_MATRIX`: Projection matrix

### Fragment Shader
- `FRAGCOORD`: Fragment position (screen space)
- `SCREEN_UV`: Screen-space UV coordinates
- `ALBEDO`: Base color output
- `METALLIC`: Metallic value output
- `ROUGHNESS`: Roughness value output
- `NORMAL_MAP`: Normal map output
- `EMISSION`: Emission output
- `ALPHA`: Transparency output
- `TIME`: Global time in seconds

## Project-Specific Notes

### Current Water Shader (water.gdshader)
- Uses vertex displacement for wave geometry
- Multiple wave frequencies combined
- Configurable amplitude, frequency, and speed
- PBR materials with metallic/roughness control
- Deep-to-surface color gradient

### Modifying Wave Behavior
1. Adjust `amplitude1`, `amplitude2` for wave height
2. Adjust `frequency1`, `frequency2` for wave density
3. Adjust `speed` for animation speed
4. Consider adding directional waves for wind effects
5. Add normal mapping for surface detail without geometry cost

### Performance Considerations
- Water shader runs on potentially large mesh (LOD system)
- Keep vertex shader calculations efficient
- Minimize fragment shader texture samples
- Use `render_mode` for optimal culling and blending

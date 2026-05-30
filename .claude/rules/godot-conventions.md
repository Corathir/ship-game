---
paths: ["**/*.tscn", "**/*.tres", "scripts/**/*.gd"]
---

# Project-Specific Godot Conventions

## Architecture

- **Forward Plus renderer** (Godot 4.6)
- **WaveCalculator** is a global autoload — single source of truth for wave heights. Access from any script.
- **gerstner.glsl** — reference doc for canonical Gerstner formula. Must stay in sync with `water.gdshader` and `wave_calculator.gd`. `WaveCalculator._validate_shader_sync()` checks at runtime.
- **DebugLogger** is a global autoload — context-aware logging. Use instead of `push_warning`/`push_error`/`print`.
- **WorldMap** is a global autoload — sphere→plane projection. `world_to_latlong(pos)`, `get_latitude(pos)`.
- **BiomeManager** is a global autoload — latitude→climate lookup (North/Temperate/Tropics).
- **WeatherManager** is a global autoload — deterministic weather by coordinate. Drives `WaveCalculator` and `ocean.gd`.
- **Water system**: procedural mesh generation via ArrayMesh with LOD rings
- **Ship physics**: probe-based buoyancy (4 probes: FL, FR, BL, BR), not real fluid simulation
- **Hybrid physics**: RigidBody3D for ship + AnimatableBody3D for walkable deck

## RigidBody3D (Ship)

- Use `apply_force()` / `apply_impulse()` — avoid directly setting velocity
- Ship defaults: `linear_damp` 2.0, `angular_damp` 3.0
- Buoyancy forces applied in `_physics_process`

## Collision Layers

- Layer 1: World geometry
- Layer 2: Player
- Layer 3: Enemies
- Layer 4: Projectiles

## Shader Parameters from GDScript

```gdscript
var material = $MeshInstance3D.material_override
material.set_shader_parameter("amplitude", 2.0)
var value = material.get_shader_parameter("amplitude")
```

## Binoculars Mechanic

Use LOD center shift to focus point for distant viewing.

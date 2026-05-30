# Drift - Maritime Survival RPG

**Engine**: Godot 4.6 (Forward Plus) | **Language**: GDScript | **Main Scene**: `ocean.tscn`

Maritime survival RPG: manage a sailing ship and crew on an infinite procedural ocean. Emergent gameplay from intersecting systems. See `game-design.md` for full design doc.

## Project Structure

```
ship/
├── ocean.tscn              # Main scene
├── ocean/
│   ├── ocean.gd            # Ocean scene controller
│   ├── water.gdshader      # Water shader (includes gerstner.glsl)
│   ├── gerstner.glsl       # Shared Gerstner wave formulas (GLSL)
│   ├── water_mesh_generator.gd  # Water mesh with LOD rings
│   └── wave_calculator.gd  # Autoload: wave physics + shader sync
├── ship/
│   ├── ship.gd             # Ship physics & buoyancy
│   └── hull_generator.gd   # Procedural hull mesh + collision
├── player/
│   ├── player.gd           # CharacterBody3D player controller
│   └── camera.gd           # Camera with debug FPS toggle
├── system/
│   └── debug_logger.gd     # Autoload: context-aware logging
└── project.godot
```

## Core Components

- **WaveCalculator** (`ocean/wave_calculator.gd`): Autoload singleton — single source of truth for wave physics. Feeds shader uniforms + provides CPU queries (`get_height`, `get_displacement`, `get_normal`, `get_foam`).
- **gerstner.glsl** (`ocean/gerstner.glsl`): Reference doc for canonical Gerstner formula. Both shader and GDScript must mirror this. `WaveCalculator._validate_shader_sync()` checks for drift at runtime.
- **WaterLOD** (`ocean/water_mesh_generator.gd`): Procedural water mesh with LOD rings (ArrayMesh). `target` must be set to Ship node.
- **Water Shader** (`ocean/water.gdshader`): Inline Gerstner vertex displacement + PBR, configurable via uniforms.
- **DebugLogger** (`system/debug_logger.gd`): Autoload singleton — context-aware logging that auto-detects caller scene/node/script.
- **Ship** (RigidBody3D): Probe-based buoyancy (FL, FR, BL, BR). `linear_damp`: 2.0, `angular_damp`: 3.0.
- **Deck** (AnimatableBody3D): Walkable surface synced with ship physics.

## Wave Parameters (in `ocean.tscn` ShaderMaterial)

- `wave_count`: 6 (max 8)
- `wave_data`: PackedFloat32Array [dir_x, dir_y, amplitude, steepness, k, omega] per wave
- Colors: Deep → Surface → SSS (subsurface scattering)
- Foam: Jacobian-based, controlled by `foam_threshold`

## Current Phase: Phase 0 — Technical Foundation

- ✅ Ocean with waves (shader + WaveCalculator)
- ✅ RigidBody3D ship with buoyancy probes
- ⏳ AnimatableBody3D deck for walking on rocking ship
- ⏳ CharacterBody3D player with deck controls
- ⏳ Movement transitions: Deck ↔ Water ↔ Land ↔ Deck

**Next**: AnimatableBody3D deck for walking on rocking ship.

## Key Technical Decisions

- RigidBody3D for ship physics + AnimatableBody3D for walkable deck
- WaveCalculator singleton synchronizes physics and visuals
- LOD optimization via ArrayMesh procedural ring generation
- Primitive placeholders for all objects (code over graphics)
- No complex ports — simple lighthouse structures

## Conventions

- **File naming**: `lowercase_with_underscores` (.tscn, .gd, .gdshader)
- **One script per file**, name matches scene/node
- **Autoloads** for global systems (WaveCalculator, DebugLogger)
- **Node names**: PascalCase, group related under containers
- **Private members**: prefix `_`
- **Constants**: SCREAMING_SNAKE_CASE
- **Always use type hints** in GDScript

## Related Files

- Game design: @.claude/game-design.md
- Rules: @.claude/rules/godot-conventions.md, script-style.md, shader-guidelines.md
- Project settings: @project.godot | Main scene: @ocean.tscn | Ship: @ship.tscn

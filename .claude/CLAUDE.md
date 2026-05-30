# Drift - Maritime Survival RPG

**Engine**: Godot 4.5 (Forward Plus) | **Language**: GDScript | **Main Scene**: `ocean.tscn`

Maritime survival RPG: manage a sailing ship and crew on an infinite procedural ocean. Emergent gameplay from intersecting systems. See `game-design.md` for full design doc.

## Project Structure

```
ship/
├── ocean.tscn              # Main scene
├── ship.tscn               # Ship (RigidBody3D)
├── scripts/
│   ├── ocean.gd            # Ocean scene controller
│   ├── ship.gd             # Ship physics & buoyancy
│   ├── camera.gd           # Camera controller
│   ├── water_mesh_generator.gd  # Water mesh with LOD
│   └── wave_calculator.gd  # Autoload: wave height
├── ocean/
│   └── water.gdshader      # Water shader
└── project.godot
```

## Core Components

- **WaveCalculator** (`wave_calculator.gd`): Autoload singleton — single source of truth for wave heights. Access globally.
- **WaterLOD** (`water_mesh_generator.gd`): Procedural water mesh with LOD rings (ArrayMesh).
- **Water Shader** (`water.gdshader`): Vertex displacement waves + PBR, configurable via uniforms.
- **Ship** (RigidBody3D): Probe-based buoyancy (FL, FR, BL, BR). `linear_damp`: 2.0, `angular_damp`: 3.0.
- **Deck** (AnimatableBody3D): Walkable surface synced with ship physics.

## Wave Parameters (in `ocean.tscn` ShaderMaterial)

- `amplitude1`: 0.5, `amplitude2`: 0.3
- `frequency1`: 0.5, `frequency2`: 0.8
- `speed`: 1.0
- Colors: Deep (#001A33) → Surface (#006680)

## Current Phase: Phase 0 — Technical Foundation

- ✅ Ocean with waves (shader + WaveCalculator)
- ✅ RigidBody3D ship with buoyancy probes
- ⏳ AnimatableBody3D deck for walking on rocking ship
- ⏳ CharacterBody3D player with deck controls
- ⏳ Movement transitions: Deck ↔ Water ↔ Land ↔ Deck

**Next**: Sync wave parameters between GDScript and shaders; WaveCalculator as single source of truth.

## Key Technical Decisions

- RigidBody3D for ship physics + AnimatableBody3D for walkable deck
- WaveCalculator singleton synchronizes physics and visuals
- LOD optimization via ArrayMesh procedural ring generation
- Primitive placeholders for all objects (code over graphics)
- No complex ports — simple lighthouse structures

## Conventions

- **File naming**: `lowercase_with_underscores` (.tscn, .gd, .gdshader)
- **One script per file**, name matches scene/node
- **Autoloads** for global systems (WaveCalculator)
- **Node names**: PascalCase, group related under containers
- **Private members**: prefix `_`
- **Constants**: SCREAMING_SNAKE_CASE
- **Always use type hints** in GDScript

## Related Files

- Game design: @.claude/game-design.md
- Rules: @.claude/rules/godot-conventions.md, script-style.md, shader-guidelines.md
- Project settings: @project.godot | Main scene: @ocean.tscn | Ship: @ship.tscn

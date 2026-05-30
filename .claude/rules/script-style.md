---
paths: ["scripts/**/*.gd"]
---

# GDScript Project Conventions

## Standard File Structure

```gdscript
## Ship controller — handles ship physics and buoyancy calculations
class_name Ship
extends RigidBody3D

# Signals
signal speed_changed(new_speed: float)

# Enums
enum State { IDLE, MOVING, SINKING }

# Constants (SCREAMING_SNAKE_CASE)
const MAX_SPEED = 50.0

# Exports
@export var mass: float = 100.0

# Public variables (snake_case, always typed)
var current_speed: float = 0.0

# Private variables (prefix _)
var _internal_state: State = State.IDLE

# Onready variables
@onready var hull = $Hull

# Lifecycle methods (in order)
func _ready():
    pass

func _physics_process(delta: float):
    pass

# Public methods
func set_speed(speed: float) -> void:
    current_speed = speed
    speed_changed.emit(speed)

# Private methods
func _calculate_drag() -> float:
    return current_speed * 0.1
```

## Project-Specific Rules

- **Always use type hints** for variables, parameters, and return types
- **WaveCalculator autoload** for consistent wave height queries — cache results when possible (expensive)
- **Physics**: use `_physics_process` for RigidBody interactions; `apply_force()` instead of direct velocity
- **Node refs**: `@onready` for children, `@export` for external references
- **Tabs** for indentation (Godot default)
- **Comments**: explain WHY, not WHAT

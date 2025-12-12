---
paths: ["**/*.tscn", "**/*.tres", "scripts/**/*.gd"]
---

# Godot Engine Conventions

## General Guidelines

### Node Hierarchy
- Keep scene trees shallow and organized
- Use meaningful, descriptive node names (PascalCase)
- Group related nodes under containers (e.g., `ProbeContainer` for all probes)
- Avoid deeply nested hierarchies (max 4-5 levels when possible)

### Scene Organization
- One main functionality per scene
- Use inheritance and instancing for reusable components
- Separate visual nodes from logic nodes
- Place scripts on root nodes or dedicated controller nodes

## GDScript Best Practices

### Script Structure
```gdscript
# Header comment explaining script purpose
extends Node3D  # or appropriate base class

# Constants (SCREAMING_SNAKE_CASE)
const MAX_SPEED = 100.0

# Exports (configurable in editor)
@export var speed: float = 10.0
@export_range(0, 100) var health: int = 100

# Public variables
var velocity: Vector3 = Vector3.ZERO

# Private variables (prefix with _)
var _internal_state: int = 0

# Onready variables (initialized when node enters tree)
@onready var mesh = $MeshInstance3D

# Built-in lifecycle methods (in order)
func _ready():
    pass

func _process(delta):
    pass

func _physics_process(delta):
    pass

# Public methods
func do_something():
    pass

# Private methods (prefix with _)
func _internal_helper():
    pass
```

### Naming Conventions
- **Variables**: `snake_case`
- **Functions**: `snake_case`
- **Constants**: `SCREAMING_SNAKE_CASE`
- **Classes**: `PascalCase`
- **Signals**: `snake_case`
- **Private members**: Prefix with `_`

### Node References
```gdscript
# Prefer @onready for node references
@onready var player = $Player
@onready var camera = $Camera3D

# Use get_node() or $ for dynamic access
var node = get_node("Path/To/Node")
var node2 = $"Path/To/Node"
```

### Signals
```gdscript
# Define signals at top of script
signal health_changed(new_health: int)
signal died

# Emit signals with typed parameters
func take_damage(amount: int):
    health -= amount
    health_changed.emit(health)
    if health <= 0:
        died.emit()
```

## Physics & Collision

### RigidBody3D
- Set appropriate damping values (linear and angular)
- Use `apply_force()` or `apply_impulse()` for physics interactions
- Avoid directly setting `linear_velocity` or `angular_velocity` when possible
- Let physics engine handle collisions

### Collision Layers & Masks
- Layer 1: World geometry
- Layer 2: Player
- Layer 3: Enemies
- Layer 4: Projectiles
- Use collision masks to control what interacts with what

## Resource Management

### Preloading
```gdscript
# Preload resources at script load time
const BULLET_SCENE = preload("res://scenes/bullet.tscn")

# Load resources at runtime (if needed dynamically)
var texture = load("res://textures/sprite.png")
```

### Resource Paths
- Always use `res://` protocol for resource paths
- Use lowercase with underscores for file names
- Organize resources in logical folders

## Autoloads (Singletons)

### When to Use
- Global game state
- Manager classes (audio, save/load, etc.)
- Utility functions used across multiple scenes
- Event buses for decoupled communication

### Example
```gdscript
# In autoload script
extends Node

var game_state = {}

func save_game():
    # Save logic
    pass

# Access from any script
func _ready():
    GameManager.save_game()  # If autoload named "GameManager"
```

## Performance Optimization

### Process Functions
- Use `_process(delta)` for visual updates
- Use `_physics_process(delta)` for physics/gameplay logic
- Disable processing when not needed:
  ```gdscript
  set_process(false)
  set_physics_process(false)
  ```

### Node Management
- Free unused nodes with `queue_free()`
- Pool frequently created/destroyed objects
- Use `call_deferred("queue_free")` for safe deletion

### Signals vs Polling
- Prefer signals over polling in `_process()`
- Use signals for event-driven behavior
- Avoid checking conditions every frame

## Debugging

### Print Statements
```gdscript
print("Message")  # Standard output
print_debug("Debug info")  # Includes stack trace
push_warning("Warning message")  # Yellow in console
push_error("Error message")  # Red in console
```

### Assertions
```gdscript
assert(condition, "Error message if false")
```

## Common Godot Patterns

### Initialization Order
1. Script variables initialized
2. `_init()` called (rarely used)
3. `_enter_tree()` called
4. `@onready` variables initialized
5. `_ready()` called
6. Node becomes active in scene

### Delta Time
```gdscript
func _process(delta):
    # Always use delta for frame-independent movement
    position += velocity * delta
```

### Input Handling
```gdscript
func _input(event):
    if event is InputEventKey:
        if event.pressed and event.keycode == KEY_SPACE:
            jump()

func _unhandled_input(event):
    # For input not handled by UI
    pass
```

## Shader Integration

### Setting Shader Parameters
```gdscript
# Access material
var material = $MeshInstance3D.material_override

# Set shader parameter
material.set_shader_parameter("amplitude", 2.0)

# Get shader parameter
var value = material.get_shader_parameter("amplitude")
```

## Project-Specific Notes

- This project uses Forward Plus renderer (Godot 4.x)
- WaveCalculator is a global autoload for wave height queries
- Water system uses procedural mesh generation
- Ship physics uses probe-based buoyancy approximation

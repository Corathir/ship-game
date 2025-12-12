---
paths: ["scripts/**/*.gd"]
---

# GDScript Style Guide

## Code Formatting

### Indentation
- Use **tabs** for indentation (Godot default)
- One tab = one indentation level
- Align continuation lines with the opening delimiter

```gdscript
# Good
func long_function_call(
    parameter1: int,
    parameter2: String,
    parameter3: bool
) -> void:
    pass

# Bad
func long_function_call(parameter1: int, parameter2: String,
parameter3: bool) -> void:
    pass
```

### Line Length
- Keep lines under 100 characters when practical
- Break long lines at logical points

### Blank Lines
- Two blank lines between top-level functions and classes
- One blank line between methods in a class
- One blank line between logical sections within a function

### Spacing
```gdscript
# Good
var x = 5
var array = [1, 2, 3]
var dict = {"key": "value"}
func add(a: int, b: int) -> int:
    return a + b

# Bad
var x=5
var array=[1,2,3]
var dict={"key":"value"}
func add(a:int,b:int)->int:
    return a+b
```

## Naming Conventions

### Variables
```gdscript
# snake_case for variables
var player_health = 100
var max_speed = 50.0
var is_alive = true

# Private variables (prefix with _)
var _internal_counter = 0
var _cached_result = null
```

### Constants
```gdscript
# SCREAMING_SNAKE_CASE
const MAX_HEALTH = 100
const GRAVITY = 9.8
const DEFAULT_SPEED = 10.0
```

### Functions
```gdscript
# snake_case for functions
func calculate_damage(base_damage: int, multiplier: float) -> int:
    return int(base_damage * multiplier)

# Private functions (prefix with _)
func _update_internal_state():
    pass

# Boolean functions (use is_, has_, can_)
func is_alive() -> bool:
    return health > 0

func has_ammo() -> bool:
    return ammo_count > 0

func can_shoot() -> bool:
    return is_alive() and has_ammo()
```

### Classes
```gdscript
# PascalCase for class names
class_name PlayerController
extends CharacterBody3D

class WeaponData:
    var damage: int
    var fire_rate: float
```

### Signals
```gdscript
# snake_case, use past tense for events
signal health_changed(new_health: int)
signal player_died
signal item_collected(item_name: String)
signal button_pressed
```

### Enums
```gdscript
# PascalCase for enum name, SCREAMING_SNAKE_CASE for values
enum State {
    IDLE,
    WALKING,
    RUNNING,
    JUMPING
}

enum WeaponType {
    MELEE,
    RANGED,
    MAGIC
}

# Access: State.IDLE, WeaponType.MELEE
```

## Type Hints

### Always Use Type Hints
```gdscript
# Good - explicit types
var health: int = 100
var speed: float = 5.0
var player_name: String = "Player"
var items: Array[String] = []

func calculate(a: int, b: int) -> int:
    return a + b

# Bad - no type hints
var health = 100
var speed = 5.0
func calculate(a, b):
    return a + b
```

### Typed Arrays and Dictionaries
```gdscript
# Typed arrays (Godot 4.x)
var numbers: Array[int] = [1, 2, 3]
var names: Array[String] = ["Alice", "Bob"]
var nodes: Array[Node] = []

# Typed dictionaries
var scores: Dictionary = {
    "player1": 100,
    "player2": 200
}

# For complex types, declare separately
var weapons: Array[Weapon] = []
```

### Return Types
```gdscript
# Always specify return type
func get_player() -> Node3D:
    return $Player

func is_ready() -> bool:
    return true

func process_data() -> void:
    # Function returns nothing
    pass
```

## Function Organization

### Parameter Order
1. Required parameters
2. Optional parameters with defaults

```gdscript
func create_enemy(
    type: String,
    position: Vector3,
    health: int = 100,
    level: int = 1
) -> Enemy:
    pass
```

### Function Length
- Keep functions short and focused (ideally under 50 lines)
- Extract complex logic into helper functions
- One function should do one thing well

```gdscript
# Good - separated concerns
func process_input():
    var direction = _get_input_direction()
    _move_player(direction)

func _get_input_direction() -> Vector2:
    return Input.get_vector("left", "right", "up", "down")

func _move_player(direction: Vector2) -> void:
    velocity = direction * speed
```

## Comments and Documentation

### When to Comment
```gdscript
# Good: Explain WHY, not WHAT
# Use quadratic formula because linear interpolation causes jitter
var result = (-b + sqrt(b*b - 4*a*c)) / (2*a)

# Bad: Comment states the obvious
# Add 1 to counter
counter += 1
```

### Function Documentation
```gdscript
## Calculates damage after applying armor reduction and critical hits.
##
## Parameters:
## - base_damage: Raw damage before modifiers
## - armor: Target's armor value (0-100)
## - is_critical: Whether this is a critical hit
##
## Returns the final damage amount (minimum 1)
func calculate_damage(base_damage: int, armor: int, is_critical: bool) -> int:
    var reduced_damage = base_damage * (1.0 - armor / 100.0)
    if is_critical:
        reduced_damage *= 2.0
    return max(1, int(reduced_damage))
```

### TODO Comments
```gdscript
# TODO: Implement enemy AI pathfinding
# FIXME: Memory leak when spawning multiple enemies
# HACK: Temporary workaround until physics bug is fixed
# NOTE: This must match the server's calculation exactly
```

## Control Flow

### If Statements
```gdscript
# Single line for simple conditions
if health <= 0: die()

# Multi-line for complex logic
if health <= 0:
    play_death_animation()
    drop_items()
    queue_free()

# Avoid unnecessary else after return
# Good
func get_status() -> String:
    if health > 50:
        return "healthy"
    if health > 0:
        return "injured"
    return "dead"

# Bad
func get_status() -> String:
    if health > 50:
        return "healthy"
    else:
        if health > 0:
            return "injured"
        else:
            return "dead"
```

### Match Statements (Switch)
```gdscript
match state:
    State.IDLE:
        handle_idle()
    State.WALKING, State.RUNNING:
        handle_movement()
    State.JUMPING:
        handle_jump()
    _:
        push_warning("Unknown state: %s" % state)
```

### Loops
```gdscript
# For loops
for i in range(10):
    print(i)

for item in inventory:
    process_item(item)

for key in dictionary:
    print("%s: %s" % [key, dictionary[key]])

# While loops
while is_processing:
    process_next_item()
    await get_tree().create_timer(0.1).timeout

# Use continue and break clearly
for enemy in enemies:
    if enemy.is_dead:
        continue
    if enemy.is_boss:
        break
    damage_enemy(enemy)
```

## Signals

### Signal Declaration
```gdscript
# Declare at top of script
signal health_changed(old_value: int, new_value: int)
signal died
signal item_picked_up(item: Item)
```

### Connecting Signals
```gdscript
# In _ready() function
func _ready():
    # Connect to own signal
    health_changed.connect(_on_health_changed)

    # Connect to other node's signal
    $Button.pressed.connect(_on_button_pressed)

    # Lambda for simple cases
    $Timer.timeout.connect(func(): print("Timeout!"))

# Signal handlers
func _on_health_changed(old_value: int, new_value: int):
    health_bar.value = new_value

func _on_button_pressed():
    print("Button pressed!")
```

## Exports

### Export Variables
```gdscript
# Basic exports
@export var speed: float = 10.0
@export var player_name: String = "Player"

# Range hints
@export_range(0, 100) var health: int = 100
@export_range(0.0, 1.0, 0.1) var opacity: float = 1.0

# Enum exports
@export_enum("Easy", "Normal", "Hard") var difficulty: String = "Normal"

# Node path exports
@export var target: Node3D
@export_node_path("Camera3D") var camera_path: NodePath

# File/directory exports
@export_file("*.json") var config_file: String
@export_dir var save_directory: String

# Group exports (organize inspector)
@export_group("Movement")
@export var walk_speed: float = 5.0
@export var run_speed: float = 10.0

@export_group("Combat")
@export var damage: int = 10
@export var attack_range: float = 2.0
```

## Error Handling

### Assertions
```gdscript
func _ready():
    assert(player != null, "Player reference is required")
    assert(speed > 0, "Speed must be positive")
```

### Error Checking
```gdscript
func load_config(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        push_error("Config file not found: %s" % path)
        return {}

    var file = FileAccess.open(path, FileAccess.READ)
    if file == null:
        push_error("Failed to open config file: %s" % path)
        return {}

    var json = JSON.new()
    var error = json.parse(file.get_as_text())
    file.close()

    if error != OK:
        push_error("Failed to parse JSON: %s" % path)
        return {}

    return json.data
```

## Project-Specific Conventions

### Wave Calculations
- Use WaveCalculator autoload for consistent wave height queries
- Cache wave calculations when possible (expensive)
- Use delta time for frame-independent movement

### Physics Integration
```gdscript
# Prefer _physics_process for RigidBody interactions
func _physics_process(delta: float) -> void:
    apply_buoyancy_forces(delta)

# Use apply_force instead of direct velocity modification
func apply_buoyancy_forces(delta: float) -> void:
    var force = calculate_buoyancy()
    body.apply_force(force, Vector3.ZERO)
```

### Node References
```gdscript
# Use @onready for child nodes
@onready var mesh = $MeshInstance3D
@onready var collision = $CollisionShape3D

# Export for external node references
@export var water_surface: Node3D
@export var camera: Camera3D
```

### Debugging
```gdscript
# Use specific print functions
print("General info")
print_debug("Debug trace with stack")
push_warning("Non-critical warning")
push_error("Critical error occurred")

# Conditional debugging
if OS.is_debug_build():
    print("Debug mode: %s" % debug_info)
```

## Code Organization in Files

### Standard File Structure
```gdscript
# 1. Header comment
## Ship controller
## Handles ship physics and buoyancy calculations

# 2. Class declaration
class_name Ship
extends RigidBody3D

# 3. Signals
signal speed_changed(new_speed: float)

# 4. Enums
enum State { IDLE, MOVING, SINKING }

# 5. Constants
const MAX_SPEED = 50.0

# 6. Exports
@export var mass: float = 100.0

# 7. Public variables
var current_speed: float = 0.0

# 8. Private variables
var _internal_state: State = State.IDLE

# 9. Onready variables
@onready var hull = $Hull

# 10. Built-in lifecycle methods
func _ready():
    pass

func _physics_process(delta: float):
    pass

# 11. Public methods
func set_speed(speed: float) -> void:
    current_speed = speed
    speed_changed.emit(speed)

# 12. Private methods
func _calculate_drag() -> float:
    return current_speed * 0.1
```

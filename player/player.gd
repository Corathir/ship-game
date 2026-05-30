# player.gd
extends CharacterBody3D

# Movement parameters
@export var move_speed := 15.0
@export var jump_velocity := 4.5
@export var mouse_sensitivity := 0.003

# Camera pivot
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
    # Capture mouse for camera control
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
    # Mouse camera control
    if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        rotate_y(-event.relative.x * mouse_sensitivity)
        camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
        camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -PI/2, PI/2)

    # Toggle mouse capture
    if event.is_action_pressed("hold_cursor"):
        if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
        else:
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
    # Apply gravity
    velocity.y -= gravity * delta

    # Jump
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity

    # Get input direction
    var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

    # Calculate movement direction relative to player rotation
    var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

    # Apply movement
    if direction:
        velocity.x = direction.x * move_speed
        velocity.z = direction.z * move_speed
    else:
        velocity.x = move_toward(velocity.x, 0, move_speed)
        velocity.z = move_toward(velocity.z, 0, move_speed)

    move_and_slide()

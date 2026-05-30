extends Camera3D

## Debug: set true to unlock FPS and disable VSync for profiling
@export var debug_unlock_fps := false

func _ready() -> void:
    if debug_unlock_fps:
        Engine.max_fps = 0
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
        DebugLogger.info("Camera: FPS unlocked, VSync disabled (debug mode)", self)

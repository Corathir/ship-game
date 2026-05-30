extends Camera3D

var time := 0.0

func _ready() -> void:
    Engine.max_fps = 0  # Убрать ограничение для теста
    DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
    
func _process(_delta: float) -> void:
    pass

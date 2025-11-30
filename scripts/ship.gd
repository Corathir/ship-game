extends Node3D

@export var float_force := 1.0

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var boat: RigidBody3D = $Boat
@onready var probes: Array[Node] = $Boat/ProbeContainer.get_children()

func _physics_process(_delta: float) -> void:
    for probe in probes:
        var pos = probe.global_position
        var water_height = WaveCalculator.get_height(pos.x, pos.z)
        var depth = water_height - pos.y
        
        if depth > 0:
            var buoyancy = Vector3.UP * float_force * gravity * depth
            boat.apply_force(buoyancy, probe.global_position - boat.global_position)

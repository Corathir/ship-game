# ocean.gd
extends Node3D

func _ready():
    var water_node = $WaterLOD
    
    # Если WaterLOD сам MeshInstance3D
    if water_node is MeshInstance3D:
        _register_from_mesh(water_node)
    # Если MeshInstance3D внутри WaterLOD
    elif water_node.get_child_count() > 0:
        for child in water_node.get_children():
            if child is MeshInstance3D:
                _register_from_mesh(child)
                break

func _register_from_mesh(mesh_instance: MeshInstance3D) -> void:
    var mat = mesh_instance.get_surface_override_material(0)
    if mat == null:
        mat = mesh_instance.mesh.surface_get_material(0)
    
    if mat is ShaderMaterial:
        WaveCalculator.register_material(mat)
        print("Ocean: материал зарегистрирован")
    else:
        push_warning("Ocean: материал не ShaderMaterial")

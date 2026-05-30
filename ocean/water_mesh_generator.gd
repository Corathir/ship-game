extends Node3D

@export var target: Node3D
@export var water_material: ShaderMaterial

var lods: Array[MeshInstance3D] = []
var lod_configs := [
    {"size": 100.0, "resolution": 200, "inner_size": 0.0},
    {"size": 400.0, "resolution": 200, "inner_size": 100.0},
    {"size": 1600.0, "resolution": 200, "inner_size": 400.0},
]

func _ready() -> void:
    _generate_lods()

func _generate_lods() -> void:
    for config in lod_configs:
        var mesh_instance := MeshInstance3D.new()
        mesh_instance.mesh = _create_ring(config.size, config.resolution, config.inner_size)
        mesh_instance.material_override = water_material
        add_child(mesh_instance)
        lods.append(mesh_instance)

func _process(_delta: float) -> void:
    if not target:
        return
    for i in range(lods.size()):
        var cell: float = lod_configs[i].size / lod_configs[i].resolution
        lods[i].global_position.x = floor(target.global_position.x / cell) * cell
        lods[i].global_position.z = floor(target.global_position.z / cell) * cell

func _create_ring(size: float, resolution: int, inner_size: float) -> ArrayMesh:
    var mesh := ArrayMesh.new()
    var vertices := PackedVector3Array()
    var indices := PackedInt32Array()
    
    var half := size / 2.0
    var inner_half := inner_size / 2.0
    var step := size / float(resolution)
    
    for z in range(resolution + 1):
        for x in range(resolution + 1):
            var pos := Vector3(
                -half + x * step,
                0.0,
                -half + z * step
            )
            vertices.append(pos)
    
    for z in range(resolution):
        for x in range(resolution):
            var world_x := -half + x * step + step / 2.0
            var world_z := -half + z * step + step / 2.0
            
            # Пропускаем ячейки внутри дырки
            if abs(world_x) < inner_half and abs(world_z) < inner_half:
                continue
            
            var i := z * (resolution + 1) + x
            indices.append(i)
            indices.append(i + 1)
            indices.append(i + resolution + 1)
            indices.append(i + 1)
            indices.append(i + resolution + 2)
            indices.append(i + resolution + 1)
    
    var arrays := []
    arrays.resize(Mesh.ARRAY_MAX)
    arrays[Mesh.ARRAY_VERTEX] = vertices
    arrays[Mesh.ARRAY_INDEX] = indices
    
    mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
    return mesh

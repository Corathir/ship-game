@tool
extends EditorScript

# Single build pass over the raw FBX (no import_script needed):
#  - exports each prop mesh (geometry only) to MESH_DIR/*.res
#  - saves the ship without props as SHIP_OUT
# Assign Mat_StylShip_Props via Material Override in each prop slice — baking it
# into the mesh surface does not survive saving to a .res.
# Run: File > Run. FBX must have NO import script.

const FBX_PATH := "res://ship/StylShip_Unity.fbx"
const MESH_DIR := "res://ship/meshes/"
const SHIP_OUT := "res://ship/ship_hull.tscn"
const PROPS := ["StylShip_Barrel", "StylShip_Box", "StylShip_Cannon", "StylShip_Pallet"]

func _run() -> void:
    if not DirAccess.dir_exists_absolute(MESH_DIR):
        DirAccess.make_dir_recursive_absolute(MESH_DIR)

    var ship = load(FBX_PATH).instantiate()

    for pname in PROPS:
        var node = ship.find_child(pname, true, false)
        if not node:
            push_warning("Prop not found: " + pname)
            continue
        if node is MeshInstance3D and node.mesh:
            var m: ArrayMesh = node.mesh.duplicate()
            var out = MESH_DIR + pname.trim_prefix("StylShip_").to_lower() + ".res"
            var err = ResourceSaver.save(m, out)
            print("Mesh %s (%s)" % [out, "OK" if err == OK else "ERR %d" % err])
        node.free()

    _reown(ship, ship)
    var packed = PackedScene.new()
    packed.pack(ship)
    var err = ResourceSaver.save(packed, SHIP_OUT)
    print("Ship without props %s (%s)" % [SHIP_OUT, "OK" if err == OK else "ERR %d" % err])

    ship.free()
    EditorInterface.get_resource_filesystem().scan()

func _reown(node, root) -> void:
    for c in node.get_children():
        c.owner = root
        _reown(c, root)

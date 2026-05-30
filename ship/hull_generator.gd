@tool
extends MeshInstance3D

## Generates a boat-shaped hull mesh from cross-sections
## and creates collision shapes for the RigidBody3D parent.

const DECK_Y := 0.5
const GUNWALE_Y := 1.5
const WALL_THICKNESS := 0.15

# [z, half_width, bottom_y]
const SECTIONS: Array[Array] = [
	[-4.5, 0.3, -0.5],
	[-3.0, 1.4, -0.9],
	[-1.0, 1.8, -1.0],
	[ 1.0, 2.0, -1.0],
	[ 3.0, 1.9, -0.9],
	[ 4.5, 1.5, -0.7],
]


func _ready() -> void:
	mesh = _build_mesh()

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.45, 0.32, 0.18)
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	material_override = mat

	if not Engine.is_editor_hint():
		_create_collisions()


# ============================================================================
# MESH GENERATION
# ============================================================================

func _build_mesh() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for i in range(SECTIONS.size() - 1):
		_add_segment(st, SECTIONS[i], SECTIONS[i + 1])

	_add_end_cap(st, SECTIONS[0])
	_add_end_cap(st, SECTIONS[SECTIONS.size() - 1])
	_add_deck(st)

	st.generate_normals()
	return st.commit()


func _add_segment(st: SurfaceTool, s0: Array, s1: Array) -> void:
	var z0: float = s0[0]; var hw0: float = s0[1]; var by0: float = s0[2]
	var z1: float = s1[0]; var hw1: float = s1[1]; var by1: float = s1[2]

	# Left wall (hull below deck + gunwale above, one continuous surface)
	_quad(st,
		Vector3(-hw0, GUNWALE_Y, z0), Vector3(-hw0, by0, z0),
		Vector3(-hw1, by1, z1), Vector3(-hw1, GUNWALE_Y, z1))

	# Bottom
	_quad(st,
		Vector3(-hw0, by0, z0), Vector3(hw0, by0, z0),
		Vector3(hw1, by1, z1), Vector3(-hw1, by1, z1))

	# Right wall
	_quad(st,
		Vector3(hw0, by0, z0), Vector3(hw0, GUNWALE_Y, z0),
		Vector3(hw1, GUNWALE_Y, z1), Vector3(hw1, by1, z1))

	# Gunwale inner faces (so walls look solid from inside)
	var iw0 := hw0 - WALL_THICKNESS
	var iw1 := hw1 - WALL_THICKNESS
	# Left inner
	_quad(st,
		Vector3(-iw0, DECK_Y, z0), Vector3(-iw0, GUNWALE_Y, z0),
		Vector3(-iw1, GUNWALE_Y, z1), Vector3(-iw1, DECK_Y, z1))
	# Right inner
	_quad(st,
		Vector3(iw0, GUNWALE_Y, z0), Vector3(iw0, DECK_Y, z0),
		Vector3(iw1, DECK_Y, z1), Vector3(iw1, GUNWALE_Y, z1))

	# Gunwale top caps (flat horizontal strips on top of walls)
	_quad(st,
		Vector3(-hw0, GUNWALE_Y, z0), Vector3(-hw1, GUNWALE_Y, z1),
		Vector3(-iw1, GUNWALE_Y, z1), Vector3(-iw0, GUNWALE_Y, z0))
	_quad(st,
		Vector3(iw0, GUNWALE_Y, z0), Vector3(iw1, GUNWALE_Y, z1),
		Vector3(hw1, GUNWALE_Y, z1), Vector3(hw0, GUNWALE_Y, z0))


func _add_end_cap(st: SurfaceTool, s: Array) -> void:
	var z: float = s[0]; var hw: float = s[1]; var by: float = s[2]
	_quad(st,
		Vector3(-hw, GUNWALE_Y, z), Vector3(hw, GUNWALE_Y, z),
		Vector3(hw, by, z), Vector3(-hw, by, z))


func _add_deck(st: SurfaceTool) -> void:
	for i in range(SECTIONS.size() - 1):
		var z0: float = SECTIONS[i][0]; var hw0: float = SECTIONS[i][1]
		var z1: float = SECTIONS[i + 1][0]; var hw1: float = SECTIONS[i + 1][1]
		var iw0 := hw0 - WALL_THICKNESS
		var iw1 := hw1 - WALL_THICKNESS
		_quad(st,
			Vector3(-iw0, DECK_Y, z0), Vector3(iw0, DECK_Y, z0),
			Vector3(iw1, DECK_Y, z1), Vector3(-iw1, DECK_Y, z1))


func _quad(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3) -> void:
	st.add_vertex(a); st.add_vertex(b); st.add_vertex(c)
	st.add_vertex(a); st.add_vertex(c); st.add_vertex(d)


# ============================================================================
# COLLISION GENERATION (runtime only)
# ============================================================================

func _create_collisions() -> void:
	var body: RigidBody3D = get_parent()
	if not body is RigidBody3D:
		push_warning("HullGenerator: parent is not RigidBody3D")
		return

	# Solid hull mass below deck
	_add_box(body, "HullCollision",
		Vector3(0, -0.25, 0), Vector3(3.6, 1.5, 8.0))

	# Left gunwale: from z=-3 to z=4 (length 7)
	_add_box(body, "GunwaleLeft",
		Vector3(-1.85, 1.0, 0.5), Vector3(WALL_THICKNESS, 1.0, 7.0))

	# Right gunwale
	_add_box(body, "GunwaleRight",
		Vector3(1.85, 1.0, 0.5), Vector3(WALL_THICKNESS, 1.0, 7.0))

	# Stern wall
	_add_box(body, "GunwaleStern",
		Vector3(0, 1.0, 4.5), Vector3(3.0, 1.0, WALL_THICKNESS))

	# Bow walls (angled)
	_add_angled_wall(body, "BowLeft",
		Vector3(-1.85, 1.0, -3.0), Vector3(-0.3, 1.0, -4.5))
	_add_angled_wall(body, "BowRight",
		Vector3(1.85, 1.0, -3.0), Vector3(0.3, 1.0, -4.5))


func _add_box(body: RigidBody3D, col_name: String, pos: Vector3, size: Vector3) -> void:
	var col := CollisionShape3D.new()
	col.name = col_name
	var box := BoxShape3D.new()
	box.size = size
	col.shape = box
	col.position = pos
	body.add_child(col)


func _add_angled_wall(body: RigidBody3D, col_name: String, from: Vector3, to: Vector3) -> void:
	var center := (from + to) / 2.0
	var dir := to - from
	var length := Vector2(dir.x, dir.z).length()
	# Rotate box so its local Z aligns with the wall direction
	var angle := atan2(dir.x, dir.z)

	var col := CollisionShape3D.new()
	col.name = col_name
	var box := BoxShape3D.new()
	box.size = Vector3(WALL_THICKNESS, 1.0, length)
	col.shape = box
	col.position = center
	col.rotation.y = angle
	body.add_child(col)

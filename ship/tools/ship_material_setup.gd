@tool
extends EditorScript

# One-shot generator: builds 6 StandardMaterial3D resources for the pirate ship
# and wires the Unity-exported textures into the correct Godot slots.
# Run from the script editor: File > Run (Ctrl+Shift+X).

# --- Adjust these two paths to where you placed the files -----------------
const TEX_DIR := "res://ship/textures/"
const OUT_DIR := "res://ship/materials/"
# -------------------------------------------------------------------------

# Group names map 1:1 to the FBX material names "Mat_StylShip_<group>".
const GROUPS := ["Decks", "Elements", "Masts", "Props", "SailsRope", "ShipHull"]
# Albedo of these groups carries a real alpha channel (sail edges, glass).
const TRANSPARENT := ["Elements", "SailsRope"]
const EMISSIVE := ["SailsRope"]

func _run() -> void:
    if not DirAccess.dir_exists_absolute(OUT_DIR):
        DirAccess.make_dir_recursive_absolute(OUT_DIR)

    for g in GROUPS:
        var mat := StandardMaterial3D.new()
        mat.resource_name = "Mat_StylShip_" + g

        # Albedo (sRGB base color)
        mat.albedo_texture = _load(TEX_DIR + "StylShip_%s_AlbedoTransparency.png" % g)

        # Normal map. NormalOpenGL == Godot convention, no green-channel flip.
        var nrm := _load(TEX_DIR + "StylShip_%s_NormalOpenGL.png" % g)
        if nrm:
            mat.normal_enabled = true
            mat.normal_texture = nrm

        # Metallic from the RED channel of the packed Unity map.
        var mtl := _load(TEX_DIR + "StylShip_%s_MetallicSmoothness.png" % g)
        if mtl:
            mat.metallic = 1.0
            mat.metallic_texture = mtl
            mat.metallic_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED

        # Roughness from the pre-inverted map (Godot roughness = 1 - Unity smoothness).
        var rgh := _load(TEX_DIR + "StylShip_%s_Roughness.png" % g)
        if rgh:
            mat.roughness = 1.0
            mat.roughness_texture = rgh
            mat.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GRAYSCALE

        # Ambient occlusion (grayscale, read from RED).
        var ao := _load(TEX_DIR + "StylShip_%s_AmbientOcclusion.png" % g)
        if ao:
            mat.ao_enabled = true
            mat.ao_texture = ao
            mat.ao_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED

        if g in TRANSPARENT:
            mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
            mat.alpha_scissor_threshold = 0.5

        if g in EMISSIVE:
            var em := _load(TEX_DIR + "StylShip_%s_Emissive.png" % g)
            if em:
                mat.emission_enabled = true
                mat.emission_texture = em
                mat.emission_energy_multiplier = 1.0

        var path := OUT_DIR + "Mat_StylShip_%s.tres" % g
        var err := ResourceSaver.save(mat, path)
        print("%s -> %s" % [mat.resource_name, "OK" if err == OK else "ERR %d" % err])

    EditorInterface.get_resource_filesystem().scan()

func _load(path: String) -> Texture2D:
    if ResourceLoader.exists(path):
        return load(path)
    push_warning("Texture not found: " + path)
    return null

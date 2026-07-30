@tool
extends EditorScript

# Wires the 6 external .tres materials into the FBX import as "Use External",
# so the binding persists in the .import file and every extracted part keeps
# its material. Run from the script editor: File > Run (Ctrl+Shift+X).

# --- Adjust to your project ----------------------------------------------
const FBX_PATH := "res://ship/StylShip_Unity.fbx"
const MAT_DIR := "res://ship/materials/"
# -------------------------------------------------------------------------

const GROUPS := ["Decks", "Elements", "Masts", "Props", "SailsRope", "ShipHull"]

func _run() -> void:
    var import_path := FBX_PATH + ".import"
    if not FileAccess.file_exists(import_path):
        push_error("Not found: %s — import the FBX into the project first." % import_path)
        return

    var cfg := ConfigFile.new()
    var err := cfg.load(import_path)
    if err != OK:
        push_error("Cannot read %s (error %d)." % [import_path, err])
        return

    # _subresources holds per-material import overrides; keep whatever is there.
    var subres = cfg.get_value("params", "_subresources", {})
    if not subres.has("materials"):
        subres["materials"] = {}
    var mats = subres["materials"]

    var bound := 0
    for g in GROUPS:
        var mat_name = "Mat_StylShip_" + g
        var tres = MAT_DIR + "Mat_StylShip_%s.tres" % g
        if not ResourceLoader.exists(tres):
            push_warning("Skipped %s - material not found: %s" % [mat_name, tres])
            continue
        var entry = {}
        entry["use_external/enabled"] = true
        entry["use_external/path"] = tres
        mats[mat_name] = entry
        bound += 1

    subres["materials"] = mats
    cfg.set_value("params", "_subresources", subres)

    err = cfg.save(import_path)
    if err != OK:
        push_error("Cannot write %s (error %d)." % [import_path, err])
        return

    # Saving the .import file makes the editor reimport on its own; calling
    # reimport_files() here would nest inside that pass and error out.
    print("Bound %d/%d materials in %s. Editor will reimport automatically." % [bound, GROUPS.size(), FBX_PATH])

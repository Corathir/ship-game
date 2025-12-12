# Local Project Notes - Дрейф

This file is for your personal notes and preferences. It won't be committed to git.

## Current Development Phase

**Phase 0: Technical Foundation** ⏳ IN PROGRESS (40-60 hrs estimated)

### Completed ✅
- Ocean with waves (shader + WaveCalculator)
- RigidBody3D ship with buoyancy probes
- Basic wave system established

### In Progress ⏳
- Synchronizing wave parameters between GDScript and shaders
- Establishing WaveCalculator as single source of truth
- AnimatableBody3D deck for walking on rocking ship
- CharacterBody3D player with deck controls
- Movement transitions: Deck ↔ Water ↔ Land ↔ Deck

### Next Up 🎯
- Complete Phase 0 foundation
- Begin Phase 1: Ship Control (rudder, sails, wind, camera)

---

## Phase Progress Tracker

| Phase | Name | Status | Hours Est. | Notes |
|-------|------|--------|------------|-------|
| 0 | Technical Foundation | ⏳ In Progress | 40-60 | Wave system done, player movement pending |
| 1 | Ship Control | 📅 Planned | 30-40 | Rudder, sails, wind |
| 2 | Ship Wear Systems | 📅 Planned | 50-70 | 6 systems + UI |
| 3 | World - Zones & Map | 📅 Planned | 60-80 | Zone structure, map UI |
| 4 | Resources | 📅 Planned | 50-70 | Inventory, gathering, repair |
| — | **Vertical Slice** | — | **230-320** | First playable prototype |
| 5 | Crew | 📅 Planned | 80-100 | AI, skills, traits |
| 6 | Contracts | 📅 Planned | 40-60 | 5 types, rewards |
| 7 | Seasons | 📅 Planned | 40-50 | Time system, migration |
| 8 | Events | 📅 Planned | 50-70 | Storms, encounters |

---

## Personal TODO

### Immediate (Phase 0)
- [ ] Sync wave parameters between shader and WaveCalculator
- [ ] Implement AnimatableBody3D deck system
- [ ] Create CharacterBody3D player controller
- [ ] Implement movement state machine (deck/water/land)
- [ ] Test transitions between movement states

### Near Future (Phase 1)
- [ ] Design rudder control system
- [ ] Implement sail mechanics with wind dependency
- [ ] Create global wind system
- [ ] Set up camera modes (deck/overview)

### Research & Questions
- [ ] How to sync AnimatableBody3D with RigidBody3D parent rotation?
- [ ] Best approach for player state transitions?
- [ ] Camera follow smoothing for rocking ship?

---

## Development Journal

### Session Notes

**[Date]**: Started importing project context from `.claude/browser`
- Consolidated all game design docs into CLAUDE.md
- Established current phase tracking
- Ready to continue Phase 0 implementation

### Key Decisions Log
- Using RigidBody3D for ship physics + AnimatableBody3D for walkable deck (hybrid approach)
- WaveCalculator singleton as single source of truth for wave parameters
- Primitive shapes for all placeholders (no 3D models in Phase 0-4)

### Problems Encountered
- *Track issues here as they come up*

### Solutions Found
- *Document solutions for future reference*

---

## Personal Preferences

### Godot Editor Settings
- *Your preferred editor settings*

### Common Commands
```bash
# Run game
godot --path . ocean.tscn

# Git workflow
git status
git add .
git commit -m "message"
```

### Shortcuts
- *Your frequently used shortcuts*

---

## Ideas & Future Improvements

### Phase 0-4 (Vertical Slice)
- Consider adding debug UI for wave parameters
- Maybe add visual buoyancy probe indicators for testing

### Post-Vertical Slice
- Binoculars mechanic: LOD center shift to focus point
- Weather effects on visibility
- Day/night cycle

### Polish Ideas (Post-MVP)
- Authentic rope physics for rigging
- Detailed damage models
- Crew conversation system

---

## Reference Links

- [Godot 4.5 Docs](https://docs.godotengine.org/en/stable/)
- [RigidBody3D Reference](https://docs.godotengine.org/en/stable/classes/class_rigidbody3d.html)
- [GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)

---

## Temporary Context

### Current Session Focus
- Completing Phase 0: Technical Foundation
- Priority: Player movement on deck

### Things to Remember
- Keep primitives simple - no art until after Phase 4
- Test each component before moving forward
- Document any architectural decisions

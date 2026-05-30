# Game Design Overview

## Gameplay Loops

**Short-term (minutes)**: React to situations - breakdowns, resource shortages, crew conflicts. Delegate or participate personally.

**Medium-term (session)**: Complete contracts. Plan routes considering seasons - fish migrate, northern waters freeze.

**Long-term (progression)**: Survival and development. Learn world patterns. Build migration routes like nomads.

**Zone Cycle (typical day)**:
- Morning: Enter new zone
- Day: Cross zone, events occur
- Evening: Next zone or stop

## Core Game Systems

### 1. Ship Wear Systems (6 systems)

| System | Description | Effect | Repair Resources |
|--------|-------------|--------|------------------|
| **Hull** | Seams separate → leaks | Water in hold | Oakum + Tar |
| **Sails** | Tear in storms | Speed drops | Canvas |
| **Rigging** | Stretches over time | Risk of breaking | Rope |
| **Bottom** | Fouling/barnacles | -30-40% speed | Careening |
| **Rudder** | Loosens | Ship drifts | Planks |
| **Bilge** | Water accumulates | Cargo spoils | Auto-pumping |

**Philosophy**: Ship is a living organism requiring constant care, not crisis management.

**Display**:
- Strategic view: Percentage bars
- Deck view: Visual damage stages

**Automation**:
- Auto: Pumping water, cleaning (no resources needed)
- By order: Repairs (consume resources)

### 2. Resource Economy

**Repair Resources** (climate-dependent sourcing):

| Resource | Source | Climate Zone |
|----------|--------|--------------|
| Planks | Islands (forest), wreckage | All zones |
| Tar | Conifer islands, trade | North |
| Oakum | Rope processing, flax, wreckage | All zones |
| Canvas | Trade, wreckage (scarce) | Trade routes |
| Rope | Hemp (tropics), trade | Tropics |
| Fat | Fish, seals (north) | North (tar alternative) |

**Consumption Resources**:
- Food: Fresh/salted fish, salt pork, hardtack, regional specialties
- Water: Rain, springs, trade
- Alcohol: Beer replaces water, rum boosts morale (excess → fights)
- Spices: Reset food monotony. Salt for preservation

**Design Principle**: Different climates provide different materials → encourages route planning and exploration

### 3. World Structure

**Zone-based world** (like provinces):
- **Total zones**: 162 hexagonal + 12 pentagonal (special lighthouse keeper zones)
- **Zone size**: ~1 day travel time
- **Borders**: Visible on map

**Zone Properties**:
- **Static**: Climate, islands, reefs, neighbors, base type
- **Dynamic**: Weather, fish (seasonal), events
- **Player-influenced**: Resource depletion, notes

**6 Zone Types**:

| Type | Features | Dangers |
|------|----------|---------|
| Fishing Waters | Fish, signs: birds, dolphins | — |
| Rain Belt | Water collection | Storms |
| Wreckage | Salvage materials | Shallows |
| Trade Route | NPC ships | Pirates |
| Dead Waters | Nothing | — |
| Storm Belt | Fast travel | Damage |

**Resource Depletion & Recovery**:
- Player decides how much to gather (manual, real-time)
- Short visit → ~1/3 resources. Long stay → can take all
- Recovery: ~5% per day, full restoration in ~20 days
- Fish: Season determines WHERE, depletes within zone
- Zones frozen when player not present

**Visual Indicators**:
- Map: Island icon changes (green → yellow → gray)
- Distance: Forest density, bird presence
- On island: Thick forest vs stumps

### 4. Climate & Seasons

**3 Climate Belts**:

| Climate | Resources | Dangers |
|---------|-----------|---------|
| **North** | Tar, seals, cod | Frostbite, ice |
| **Temperate** | Planks, apples, beer | Base region |
| **Tropics** | Rope, fruit, spices, rum | Fever |

**4 Seasons** (10 days each, 40-day year):

| Season | Fish Migration | Special Features |
|--------|----------------|------------------|
| Spring | South→Temperate | Ice melts, moderate storms |
| Summer | In Temperate | North accessible, fruit, fever risk |
| Autumn | →North | Frequent storms, time to leave north |
| Winter | In North | Dangerous ice, frostbite |

### 5. Crew System

**8-12 crew members**, each with:
- Skills (carpenter, sailor, fisher, doctor, cook)
- Personality traits (hot-tempered, greedy, cowardly, etc.)
- Relationships (positive/negative between members)
- State (hunger, fatigue, morale)
- Secrets

**Emergent dynamics**: Systems intersect → rare situations (fights, theft, panic)

**AI & Delegation**:
- Crew auto-performs assigned tasks
- Player sets priorities
- Direct participation provides bonuses

### 6. Contracts & Economy

**5 Contract Types**:

| Type | Description | Deposit |
|------|-------------|---------|
| Delivery | Cargo A→B | Yes |
| Transport | Passenger | Possible |
| Scouting | Check location | No |
| Gathering | Bring resource | No |
| Search | Find something | No |

**Philosophy**: Contract says WHERE. Player decides HOW.

**Economy**:
- Barter system (money is one resource type)
- No reputation (yet)
- Deposit: Buy cargo, get return + payment on completion

**Trade**: Ship-to-ship via rowboats. Player gives remote instructions. Negotiator traits matter.

### 7. Navigation System

Progressive historical approach mirroring real maritime development:
- Visual methods (landmarks, birds, water color)
- Weather patterns
- Maps & charts
- Rumors & crew observations
- Seasonal patterns (fish migration)
- Future: Celestial navigation (sextant, chronometer)

**No GPS**: Players must learn the world like real sailors.

---

## Development Roadmap

### MVP Development Plan
**Total estimate**: 322-452 hours
**Development philosophy**: Code over graphics. All objects use primitives (boxes, cylinders, capsules).

### Phase 0: Technical Foundation ⏳ IN PROGRESS
**Goal**: Ship floats, player can walk on it
**Estimate**: 40-60 hours

**Tasks**:
- ✅ Ocean with waves (shader + WaveCalculator)
- ✅ RigidBody3D ship with buoyancy probes
- ⏳ AnimatableBody3D deck for walking on rocking ship
- ⏳ CharacterBody3D player with deck controls
- ⏳ Movement transitions: Deck ↔ Water ↔ Land ↔ Deck

**Current Status**: Wave system established. Need to sync parameters between GDScript and shaders, establish WaveCalculator as single source of truth.

**Result**: Can walk on rocking ship and jump into water

### Phase 1: Ship Control
**Goal**: Ship goes where you tell it
**Estimate**: 30-40 hours

- Rudder (turning via apply_torque)
- Sails (forward thrust, wind-dependent)
- Wind system (global direction, changes over time)
- Camera (follow modes: deck/overview)

**Result**: Can sail ocean and maneuver

### Phase 2: Ship Wear Systems
**Goal**: Ship requires attention
**Estimate**: 50-70 hours

- ShipSystem component (base class)
- 6 concrete systems (hull, sails, rigging, bottom, rudder, bilge)
- UI condition bars
- Color-coded damage indicators
- Auto-pumping (no resources)

**Result**: Ship gradually deteriorates, visible damage

### Phase 3: World - Zones & Map
**Goal**: Places to sail to
**Estimate**: 60-80 hours

- Zone structure (Resource: type, climate, resources, neighbors)
- 6 zone types
- 3 climates
- World generator (hex grid: 162 zones + 12 pentagons)
- Strategic map UI
- Zone transition system

**Result**: World of different zones, map shows location

### Phase 4: Resources
**Goal**: Things to gather and spend
**Estimate**: 50-70 hours

- Inventory system (ship + player)
- Gathering from islands/wreckage
- Repair mechanics (resources → system restoration)
- Inventory UI
- Zone depletion & recovery

**Result**: Full cycle: find → gather → repair

### VERTICAL SLICE (Phases 0-4)
**Total: 230-320 hours**

After these phases: Playable prototype exists. Sail around, ship breaks, find resources, repair. Can test and demonstrate.

### Phase 5: Crew (80-100 hrs)
Crew AI, skills, traits, relationships, needs

### Phase 6: Contracts (40-60 hrs)
Contract system, 5 types, rewards

### Phase 7: Seasons (40-50 hrs)
Time system, seasonal effects, fish migration

### Phase 8: Events (50-70 hrs)
Random events, storms, encounters, crew incidents

---

## Development Principles

### Solo Development Approach

1. **Code over graphics**: All objects use primitives. Models come later.
2. **Vertical slice first**: All systems at minimum, then deepen.
3. **Test early**: Each phase ends with playable build.
4. **Single focus**: Don't jump between phases. Finish, then move on.
5. **Incremental implementation**: Small testable steps to avoid overwhelming debugging.

### Primitive Placeholders

| Object | Primitive | Color/Indicator |
|--------|-----------|-----------------|
| Ship hull | Stretched Box | Brown → red when damaged |
| Mast | Cylinder | Gray |
| Sails | Plane | White → torn texture |
| Player | Capsule | Blue |
| Crew NPCs | Capsule | Green/yellow/red by state |
| Islands | Box/Sphere | Green |
| Wreckage | Small Box | Brown |
| Bilge water | Plane | Blue translucent |

### Design Philosophy

- **Constant ship maintenance** provides authentic foundation for engaging downtime gameplay (historical research: real crews had continuous varied work)
- **Hierarchy**: Ocean threats > crew social issues (maintains adventure atmosphere)
- **Resource scarcity** drives movement between climate zones
- **Direct control + strategic delegation**: All routine tasks delegatable through menus, personal involvement provides bonuses
- **Procedural events** preferred over complex NPC ship simulations (scope management)
- **Emergent gameplay** over scripted content
- **Historical authenticity** balanced with playable complexity

### Technical Decisions

- **Realistic physics**: Authentic maritime mechanics while maintaining playability
- **Hybrid approach**: RigidBody3D for ship wave physics + AnimatableBody3D for walkable deck
- **Single source of truth**: WaveCalculator singleton synchronizes physics and visuals
- **LOD optimization**: ArrayMesh for procedural ring generation
- **No complex ports**: Simple lighthouse structures to minimize art assets (cost-conscious)

---

## Key Learnings & Context

- Player emphasizes emergent gameplay over scripted content
- Ocean/external threats as primary focus, ship maintenance as secondary, crew social dynamics as tertiary "seasoning"
- Prioritizes historical authenticity balanced with playable complexity
- Using primitive shapes for placeholder graphics while building robust underlying systems
- Detailed written specifications preferred over complex multi-reference approaches
- Maritime terminology should be clarified for team accessibility

---

## Reference Materials

- **Ship design**: 18th century Hoy vessel specifications
- **Navigation**: Historical maritime practices for authentic mechanics
- **World design**: 162 hexagonal zones + 12 pentagonal zones with mysterious lighthouse keepers
- **Seasonal patterns**: Climate-based resource distribution and migration

# PushTheLand — Execution Plan (Godot 4)

## 0. Project snapshot
- Engine: Godot 4.x (GDScript 2.0 typed)
- Core presentation: square grid board (usually 9x9, sometimes smaller; max 9x9)
- Core loop per level: **spawn 100 themed cards in random order → Boss appears → defeat Boss → choose next theme (3 card boxes)**
- Key interaction: **drag & drop cards** across board / hero panel / trash zone
- Strategy layer: boss preview at level start (name, skills, weakness)

## 1. Game pillars
1) Drag-centric tactile gameplay (fast, readable, low-friction)
2) Data-driven content (themes/cards/merge rules via Resources; add content without code)
3) Strategy: boss preview + targeted merges/equipment planning
4) Replayability: branching theme choice, different playstyles (build/trap/solo)

## 2. Systems breakdown (high level)
### Board & Placement
- Grid occupancy model (cell coords -> placed card instance)
- Visual grid (9x9 default; support NxN <= 9)
- Hover highlight: show all mergeable partners for the hovered card

### Cards
- Card types:
  - Terrain component
  - Spirit
  - Equipment (weapon/armor/trinket)
  - Utility/Item (optional later)
  - Enemy card (generated result, not in base deck)
- Drag behaviors:
  - Drop on board cell: place or attempt merge
  - Drop on hero panel: equip or trigger combat (enemy)
  - Drop on trash zone: delete -> small XP

### Merge & Recipes
- Merge rule engine (data-driven):
  - card + card -> new card (upgrade / terrain completion / elite spirit)
  - spirit + spirit -> elite spirit
  - terrain components -> complete terrain
- UX: when hover card A, highlight all cards that can merge with A (by rule lookup)

### Hero & Progression
- Hero exists outside board (UI panel)
- Stats: HP, ATK, DEF
- XP sources: kill enemies, trash cards, objectives
- Level-up: stats grow; unlock talent/passive slots (later)

### Spirits -> Enemies (Dynamic)
- spirit + complete terrain -> enemy (terrain-specific)
- elite spirit + complete terrain -> elite enemy (harder, better drops)

### Enemy & Combat (MVP first)
- Minimal combat for slice: when combat triggers, resolve damage ticks until one side dies
- Drop + XP reward on victory

### Level & Theme flow
- Level start: Boss preview UI
- Spawn 100 cards according to theme deck list
- Boss spawns after 100
- After boss defeat: ThemeChoice (3 card boxes) -> load next theme

## 3. Milestones

### M0 — Foundation (Project skeleton + docs)
**Scope**
- Create core scenes, baseline scripts, Resource schemas, debug utilities.
**Deliverables**
- docs/GDD.md, docs/DATA_SCHEMA.md, docs/SCENE_TREE.md (initial)
- res://scenes/Main.tscn (boot)
- res://scenes/Board.tscn, res://scenes/ui/HeroPanel.tscn, TrashZone.tscn, BossPreview.tscn, ThemeChoice.tscn
- Base scripts under res://scripts/...
**Acceptance**
- Project runs to Main; board & UI panels visible
- Debug overlay can show: RNG seed, spawned count, board occupancy count
**Verification**
- Run Main scene; confirm UI zones exist and respond to placeholder interactions
**Risks**
- Over-engineering early. Mitigation: keep M0 minimal and support M1 only.

### M1 — Vertical Slice (Swamp theme) — complete 100 cards -> Boss -> Victory -> ThemeChoice
**Scope**
- Implement full loop for a single theme (Swamp) with minimal but playable rules.
**Deliverables**
- Card spawning system (100 cards random order from theme deck)
- Drag & drop: board place, hero equip, trash delete
- Merge rules (>= 3 recipes), hover highlight mergeable partners
- Boss preview (static data)
- Boss spawn after 100, minimal combat, win condition
- ThemeChoice UI (3 boxes) placeholder navigation
**Acceptance**
- Player can finish a run: place/merge/trash/equip; boss appears; defeat boss; reach ThemeChoice
**Verification**
- Start run with deterministic seed; confirm boss spawns exactly after 100th card
- Confirm merge highlight matches rule set
- Confirm trash gives XP and updates hero UI
**Risks**
- Drag UX is fiddly. Mitigation: snapping, clear drop zones, hover preview.

### M2 — Theme branching (3 boxes) + multiple themes (City / Swamp / Sanctuary)
**Scope**
- Real theme switching and deck definition per theme.
**Deliverables**
- ThemeDef Resources for 3 themes
- ThemeChoice loads next level with selected theme
- Theme-bound visuals (background/card frame) minimal
**Acceptance**
- Completing a level leads to 3 choices; each loads different theme with different deck mix

### M3 — Spirits + Terrain => Enemy; Spirit + Spirit => Elite Spirit
**Scope**
- Replace placeholder enemy generation with the designed dynamic system.
**Deliverables**
- Complete terrain state recognition from components
- Spirit->Enemy conversion rules per terrain
- Elite spirit + terrain -> elite enemy
**Acceptance**
- Player can intentionally create enemies via spirit + terrain, and gain rewards

### M4 — Hero progression + objectives
**Scope**
- XP/level system, simple objectives.
**Deliverables**
- XP curve, leveling, stats growth, objective definitions
**Acceptance**
- Player can level within a run; stats meaningfully affect combat

### M5 — Playstyle enablers (Build / Trap / Solo) — 1 representative mechanic each
**Scope**
- Make three approaches viable.
**Deliverables**
- City: defensive building or aura (tower / buff)
- Trap: poison/floor spike
- Solo: equipment rarity + simple affixes
**Acceptance**
- Each playstyle can beat boss with different strategy

### M6 — Content pipeline + polish
- Save/progression, balancing, FX/SFX, performance, content authoring docs

## 4. Backlog (nice-to-have)
- Replay system (record input + seed)
- Tutorials / hinting
- Accessibility options (snap strength, colorblind highlights)
- More bosses and theme-specific mechanics

## 5. Decisions log
- 2026-01-20: Default branch is master; remote uses SSH for GitHub push stability.
- 2026-01-20: Use manual drag (CardView _gui_input/_process) + CardLayer hit dispatch; avoid Control drag/drop due to CanvasLayer/mouse filter/hit issues blocking drop targets.
- 2026-01-20: Drop hit-testing uses visible ColorRect areas (HeroPanel/TrashZone) to avoid root Control size mismatches; dispatch priority is TrashZone > HeroPanel > Board via accept_drop/can_accept_drop.

## 6. Debug/Test strategy
- Deterministic RNG seed toggle
- Debug HUD: spawned count, boss state, board occupancy, current theme
- Event log: spawn, place, merge, delete, combat start/end

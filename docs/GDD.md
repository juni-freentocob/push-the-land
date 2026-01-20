# PushTheLand — Game Design Document (Godot 4)

## 1. Core loop (per level)
1) Level starts:
- Show **Boss Preview**: portrait/name/core skills/weakness attribute
2) System spawns **100 cards** in randomized order from current theme deck
3) After 100th card is spawned: **Boss appears**
4) Player defeats Boss -> Level complete
5) Present **3 card boxes** (theme branching) -> player chooses next level theme

## 2. Board & hero separation
- Board is a square grid, usually **9x9**, occasionally smaller; max 9x9.
- Hero exists outside the board (side UI panel).
- Board is the carrier for card placement, merges, terrain building.

## 3. Card drag interactions
All cards are manipulated by mouse drag & drop.

### 3.1 Drop on Hero (HeroPanel)
- Equipment card -> equip -> hero stats increase
- Enemy card (or spirit-converted enemy) -> triggers combat; hero initiates attack

### 3.2 Drop on Board (Grid cell)
- If cell empty -> place
- If cell occupied -> attempt merge based on data-driven MergeRule

### 3.3 Drop on Trash (TrashZone)
- Delete card -> gain small fixed XP
- Goal: prevent board clog, provide steady XP trickle

### 3.4 Hover UX
- When hovering a card, highlight all cards on board that can merge with it.

## 4. Card types (initial)
- Terrain Component: building blocks for terrains
- Spirit: the core enemy-generation material
- Equipment: weapon/armor/trinket
- Junk: low value, mainly for trash XP
- (Generated) Enemy: not in base deck; produced from Spirit + Terrain

## 5. Spirit & terrain driven enemy generation
- Spirit + Complete Terrain -> Enemy (terrain-specific)
- Spirit + Spirit -> Elite Spirit
- Elite Spirit + Complete Terrain -> Elite Enemy
- Enemies actively attack hero (MVP: simplified combat loop)

## 6. Terrain merges and environmental effects (phased)
- Terrain components merge into complete terrains (e.g. cemetery, swamp, city ruins).
- Complete terrain can have passive effects (later milestones):
  - City: towers buff defense/auto attack
  - Swamp: poison pools apply DoT to non-swamp enemies
  - Sanctuary: holy buffs/purify mechanics

## 7. Progression
- XP sources:
  - Kill enemy (small), elite (medium), boss (large)
  - Trash deletion (small fixed)
  - Objectives (optional early; stronger rewards)
- Level up:
  - Increase base stats (HP/ATK/DEF)
  - Unlock skill slots / passive talents (later)

## 8. Themes (4 major) and branching
- Levels are not linear; after each boss, show 3 boxes => choose next theme.
- Each theme changes:
  - Deck composition
  - Visual style
  - Gameplay emphasis (City build/defense, Swamp poison/environment, Sanctuary holy/purify, etc.)

## 9. MVP focus (Vertical Slice)
- Implement one theme (Swamp) fully:
  - 100-card spawn -> boss -> win -> theme choice UI
  - Minimal set of merges, equipment, trash XP, boss preview, combat

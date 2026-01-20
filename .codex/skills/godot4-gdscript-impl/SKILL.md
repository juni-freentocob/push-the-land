---
name: godot4-gdscript-impl
description: Implement Godot 4 features in typed GDScript 2.0 with scenes, Resources, signals, and verification steps. Output runnable code.
---

# General rules
- Godot 4 ONLY. GDScript 2.0 typed annotations, @export, @onready, signals.
- If asked to modify code: output complete, directly runnable scripts (not patch fragments).
- Use clear file paths under res:// (e.g., res://scripts/board/board.gd).
- Prefer composition and signals over tight coupling.
- Add minimal debug tooling: deterministic RNG seed, toggleable debug overlay, log key events.


# Project architecture (baseline)
## Scenes
- res://scenes/Main.tscn
- res://scenes/Board.tscn
- res://scenes/ui/HeroPanel.tscn
- res://scenes/ui/TrashZone.tscn
- res://scenes/ui/BossPreview.tscn
- res://scenes/ui/ThemeChoice.tscn
- res://scenes/cards/CardView.tscn

## Data (Resources)
- res://data/cards/CardDef.gd (+ .tres)
- res://data/terrains/TerrainDef.gd (+ .tres)
- res://data/spirits/SpiritDef.gd (+ .tres)
- res://data/enemies/EnemyDef.gd (+ .tres)
- res://data/merge/MergeRule.gd (+ rules)
- res://data/themes/ThemeDef.gd (deck composition, visuals, boss)

## Core interactions
- Drag card to Board cell: place / attempt merge
- Drag equipment to HeroPanel: equip
- Drag enemy (or spirit->enemy result) to HeroPanel: trigger combat
- Drag card to TrashZone: delete + small XP
- Hover card: highlight all mergeable matches on board

## Level loop
- Level start: show BossPreview (portrait/name/skills/weakness)
- Spawn 100 cards in randomized order (theme-bound)
- After 100: spawn Boss
- Boss defeated: ThemeChoice (3 boxes) -> next level

# Workflow for each task
1) Read PLANS.md + docs/SCENE_TREE.md + docs/DATA_SCHEMA.md
2) Implement smallest verifiable increment
3) Update docs + provide verification checklist
# Output contract (important)
For any feature task, respond in two phases:
PHASE 1 — Editor Checklist:
- Scenes/nodes to create/rename
- Node paths and required components
- Inspector properties to set (layers, groups, collision, anchors, camera, fonts, textures)
- Resource (.tres) to create and where
Wait for user confirmation.

PHASE 2 — Code:
- Provide complete, directly runnable GDScript files
- List modified files + exact paths
- Provide Godot Editor verification checklist


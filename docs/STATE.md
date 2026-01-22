# PushTheLand — State Snapshot

## Current Status (T1–T3)
T1 (Project skeleton)
- Main/Board/UI scenes in place
- Scripts wired with basic logging and signals

T2 (Drag & drop baseline)
- Manual drag (CardView _gui_input/_process) implemented
- CardLayer dispatches drop by hit-testing UI ColorRect areas
- Targets implement accept_drop(card_view) and optional can_accept_drop(card_view)

T3 (Board placement + GridVisual)
- Logical grid: board_size/cell_size
- Placement + occupancy: snap, same-cell reject, out-of-bounds reject
- Repositioning placed cards supported
- Drag flow unchanged (manual drag + CardLayer dispatch)
- GridVisual debug rendering (border, grid lines, hover cell)

T4 (Resources + Swamp data)
- Resource scripts: CardDef / ThemeDef / MergeRule (typed + class_name)
- Swamp data: swamp_spirit (SPIRIT), swamp_mud (TERRAIN_PART), wood_spear (EQUIPMENT with atk_bonus)
- swamp_theme.tres: deck_weights set; boss_id placeholder
- swamp_rules.tres: 1 MVP rule (spirit + mud -> swamp_enemy)
- MissingResource/class_name issues resolved (Inspector editable)

## Key Decisions
- Manual drag/drop only (no Control drag/drop APIs)
- Drop priority: TrashZone > HeroPanel > Board
- Placement snap: center-to-center (card center to cell center)
- GridVisual is debug-only; visuals can be replaced without changing logic
- T4 resources and .tres data are in place; boss_id and swamp_enemy are placeholders
- RNG is configurable via Main export vars (fixed seed or system time)

## Current Implementation Notes
- Board placement uses occupancy map keyed by Vector2i cells
- CardView can be reparented to Board/OccupancyLayer and remain draggable
- CardLayer hit-tests ColorRect bounds for UI drops

## Next Steps (Planned)
- T5: Card spawner, deterministic RNG seed, debug HUD
- T5: Card spawner, deterministic RNG seed, debug HUD
- T6: Merge rules + hover highlight
- T7: Boss preview + boss spawn + ThemeChoice flow
- T8: MVP combat + XP + trash rewards

## Verification Checklist (Current)
- Drag card to HeroPanel: prints accept_drop log
- Drag card to TrashZone: prints accept_drop log
- Drag card to Board: snaps to grid center
- Drag card to occupied cell: rejected and returns to original
- GridVisual visible: border, grid lines, hover cell

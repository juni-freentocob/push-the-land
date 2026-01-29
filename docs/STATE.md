# PushTheLand 鈥?State Snapshot

## Index
- M1.1 测试计划 -> docs/TEST_PLAN_M1_1.md


## Current Status (T1鈥揟8)
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

T5 (Spawner + RNG + DebugHUD)
- Theme-driven spawn (ThemeDef.deck_weights)
- Deterministic RNG (fixed seed or system time)
- DebugHUD shows seed/theme/spawned count
- Spawn layout: first grid cells; extras stacked in OverflowArea

T6 (Merge + Hover + Overflow)
- MergeRule data-driven; order-insensitive match
- Merge generates swamp_enemy MVP output
- Hover highlight stable during drag; dragged card not highlighted
- OverflowArea holds cards beyond 9x9, avoids UI blocking

T7 (BossPreview + ThemeChoice)
- BossPreview shows name/weakness/skills (placeholder)
- Boss spawn placeholder after 100 cards
- DebugBossButton triggers boss defeat and ThemeChoice
- ThemeChoice selection hides UI
- Boss spawn is a state event only; combat remains placeholder

T8 (MVP combat + rewards)
- Trash rewards: drop card in TrashZone -> XP +1
- Equipment: drop wood_spear in HeroPanel -> ATK +1
- Combat: drop swamp_enemy in HeroPanel -> HP down, XP +2
- UI stats (HP/ATK/DEF/XP) update live

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
- M2: Theme branching (3 boxes) + multiple themes

## M1.1 Status
- T9: Boss real loop (no DebugBossButton dependency) — DONE
- T10: Spirit + terrain -> enemy as main path — DONE
- T11: Drop + growth loop to make boss winnable — TODO
- T12: ThemeChoice leads to a real new round — TODO
- T13: Docs + verification updates — TODO

## Recent Decisions (M1.1)
- Boss no longer depends on DebugBossButton; ChallengeBossButton drives combat.
- ThemeChoice locks card drag until a choice is made.
- Main path (spirit + complete terrain) is enabled; MergeRule spirit+mud stays for now.

## Verification Checklist (Current)
- Drag card to HeroPanel: prints accept_drop log
- Drag card to TrashZone: prints accept_drop log
- Drag card to Board: snaps to grid center
- Drag card to occupied cell: rejected and returns to original
- GridVisual visible: border, grid lines, hover cell

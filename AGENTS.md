# Project rules (Godot 4)
- Godot 4.x only, GDScript 2.0 typed.
- For complex features, consult and update PLANS.md.
- Prefer Resource-driven data definitions (CardDef/TerrainDef/SpiritDef/ThemeDef).
- Every change must include verification steps runnable in editor.
- Keep architecture consistent: Board + UI panels separated; drag/drop is signal-driven.
- Drag/drop uses manual drag + CardLayer hit dispatch; do not use Control drag/drop APIs unless explicitly requested.
- Drag/drop flow (stable): CardView uses _gui_input/_process for real movement; CardLayer dispatches on release by hit-testing UI ColorRect areas; targets implement accept_drop(card_view) and optional can_accept_drop(card_view).
- CardView interactive rect must match its visual size (e.g., 64x64); avoid oversized root rects to prevent mis-pick.

## Collaboration protocol (Godot Editor vs Code)
- Treat Godot Editor actions (creating nodes/scenes, setting layers, assigning sprites/fonts/materials, camera setup, inspector properties) as USER-EXECUTED steps.
- When a task requires Editor changes, first output an "Editor Checklist" (exact clicks/steps, node paths, properties to set).
- Do NOT assume scenes/nodes/resources exist unless verified in repo files.
- After the user confirms "Editor Checklist done", then write/modify GDScript code.
- Always include verification steps the user can run in the Godot Editor.

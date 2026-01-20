# Project rules (Godot 4)
- Godot 4.x only, GDScript 2.0 typed.
- For complex features, consult and update PLANS.md.
- Prefer Resource-driven data definitions (CardDef/TerrainDef/SpiritDef/ThemeDef).
- Every change must include verification steps runnable in editor.
- Keep architecture consistent: Board + UI panels separated; drag/drop is signal-driven.

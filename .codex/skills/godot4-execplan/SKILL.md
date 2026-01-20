---
name: godot4-execplan
description: Create/maintain a milestone execution plan for a long Godot 4 project (PLANS.md, GDD, schema, verification).
---

# Goal
You are Codex working on a Godot 4 (NOT Godot 3) card-drop + board (<=9x9) game.
Produce a complete, long-horizon, milestone-based plan and keep it as a living document.

# Non-negotiables
- Engine: Godot 4.x, GDScript 2.0 typed style.
- Prefer data-driven design with Resources for card/terrain/spirit/enemy/boss definitions.
- Every milestone must have:
  - Scope
  - Deliverables (exact files/scenes/scripts)
  - Acceptance criteria
  - Verification steps (how to test in editor)
  - Risks & mitigations
- Always propose a Vertical Slice milestone first.
- Avoid vague language. Prefer checklists and concrete file paths.
- If unknown, pick a reasonable default and record it under Decisions.

# Required docs in repo
Create/update:
- AGENTS.md
- PLANS.md
- docs/GDD.md
- docs/DATA_SCHEMA.md
- docs/SCENE_TREE.md

# PLANS.md structure
1. Overview & Game Pillars
2. Core Loop spec (100 cards -> boss)
3. Systems breakdown
4. Milestones (M0..Mn)
5. Backlog
6. Decisions log (date-stamped)
7. Test/Debug strategy (deterministic seed, debug HUD, replay/repro)
8. Content pipeline (add cards/themes without code changes)

# Output format (when user asks for a plan)
- Show relevant milestone(s) and which docs will be updated.
- List exact files to create/modify and why.
- End with verification checklist.

# M2 Test Plan (System-first Regression)

This plan tracks M2 tasks T14..T19 and defines the minimum regression checks that must pass before each merge.

## Scope
- Replace hardcoded gameplay/control paths with maintainable runtime contracts.
- Keep M1 playable loop stable while migrating system boundaries.

## Task Matrix
- T14: Combat resolution entrypoint formalization
- T15: Enemy/type recognition migration to CardDef.kind
- T16: Data registry/resolver loading layer
- T17: Startup validator and readable error reporting
- T18: Unified state machine and logging format
- T19: Regression suite completion and handoff

## T14 Verify
Preconditions:
- BossReady reached.
Actions:
1. Click Challenge Boss.
2. Click ResolveCombatButton repeatedly.
3. (Optional) Toggle/use DebugDamage only for debug-path verification.
Expected:
- Challenge Boss does not directly defeat boss.
- HP changes through ResolveCombatButton combat rounds in main flow.
- Boss is defeated only when HP reaches 0.
- DebugDamage is optional debug-only path (not required for normal flow).
- Output contains readable state logs: Boss ready -> Boss fight started -> ResolveCombat damage -> Boss defeated.

## T15 Verify
Preconditions:
- Swamp and City themes both available.
Actions:
1. Spawn and drag enemy cards from both themes to HeroPanel.
Expected:
- Enemy recognition works without id suffix dependency as primary path.
- Migration fallback behavior documented if present.

## T16 Verify
Preconditions:
- Resolver/registry enabled.
Actions:
1. Switch theme and run spawn/merge paths.
2. Break one resource path intentionally.
Expected:
- Runtime loads via resolver.
- Missing resource error is explicit and references file/field.

## T17 Verify
Preconditions:
- Validator runs at startup.
Actions:
1. Inject invalid card_id in deck_weights.
2. Inject invalid merge_rule_paths entry.
Expected:
- Validator reports readable errors in Output/HUD.
- Fixes remove errors on next run.

## T18 Verify
Preconditions:
- Unified state machine active.
Actions:
1. Run full loop: Spawn -> BossReady -> BossFight -> BossDefeated -> ThemeChoice -> NextRun.
Expected:
- State transitions are logged with normalized format.
- ThemeChoice open locks interaction; close unlocks.

## T19 Verify
Actions:
1. Execute T14..T18 verify list in sequence.
2. Record pass/fail and residual risks.
Expected:
- All critical regressions pass.
- Known limitations are documented in STATE/PLANS.

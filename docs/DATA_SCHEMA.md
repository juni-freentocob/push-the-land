# Data Schema (Godot 4 Resources)

## 1) CardDef (res://data/cards/CardDef.gd)
Represents a card type (not an instance).
Fields (suggested):
- id: StringName (unique)
- display_name: String
- kind: enum { TERRAIN_PART, SPIRIT, EQUIPMENT, JUNK, GENERATED_ENEMY }
- rarity: enum { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY } (optional for MVP)
- icon: Texture2D (optional early)
- theme_tags: PackedStringArray (e.g., ["swamp"])
- stackable: bool (usually false)
- equipment_slot: enum { NONE, WEAPON, ARMOR, TRINKET } (only for EQUIPMENT)
- stats: Dictionary or dedicated Resource (e.g., atk_bonus, def_bonus, hp_bonus)
- terrain_part: TerrainPartRef? (links to terrain assembly; only for TERRAIN_PART)
- spirit_tier: enum { NORMAL, ELITE } (only for SPIRIT)
CardKind values:
- TERRAIN_PART
- SPIRIT
- EQUIPMENT
- JUNK
- GENERATED_ENEMY
Notes:
- atk_bonus lives in stats for EQUIPMENT (e.g., {"atk_bonus": 1})

## 2) MergeRule (res://data/merge/MergeRule.gd)
A single recipe rule.
Fields:
- id: StringName
- inputs: Array[StringName]  (2 card ids; order-insensitive)
- output: StringName         (card id)
- consume_inputs: bool = true
- output_count: int = 1
- notes: String
Notes:
- inputs are order-insensitive
- swamp_enemy is MVP merge output placeholder (T7/T8 will map to real EnemyDef/combat)
Interaction rules:
- Main path: SPIRIT + complete TERRAIN -> ENEMY
- Component merge: apply MergeRule (order-insensitive) for specific recipes
- If both could apply, main path takes priority over MergeRule

## 3) TerrainDef (res://data/terrains/TerrainDef.gd)
Defines a complete terrain type.
Fields:
- id: StringName
- display_name: String
- required_parts: Array[StringName] (card ids for components)
- theme_tags: PackedStringArray
- passive_effect_id: StringName (optional)
- enemy_table_id: StringName (maps spirit->enemy)
Notes:
- Complete terrain can be flagged via CardDef.stats["complete_terrain"]=true

## 4) SpiritDef (optional separate; or encode on CardDef kind=SPIRIT)
If separate:
- id: StringName
- tier: NORMAL/ELITE
- theme_tags
- base_modifiers (optional)

## 5) EnemyDef (res://data/enemies/EnemyDef.gd)
Fields:
- id: StringName
- display_name: String
- max_hp: int
- atk: int
- def: int
- weakness: StringName (e.g., "holy", "fire") (for MVP: string)
- loot_table_id: StringName (optional)
- xp_reward: int

## 6) BossDef (can reuse EnemyDef with is_boss flag)
Fields:
- enemy_id: StringName (EnemyDef)
- portrait: Texture2D (optional)
- skills: PackedStringArray (strings for MVP)
- weakness: StringName

## 7) ThemeDef (res://data/themes/ThemeDef.gd)
Fields:
- id: StringName
- display_name: String
- deck: Array[StringName] (list of CardDef ids; for MVP we can generate 100 from weights)
- deck_weights: Dictionary[StringName, int] (card_id -> weight; keys must match card resource ids for that theme)
- boss_id: StringName (BossDef or EnemyDef id)
- output_remap: Dictionary[StringName, StringName] (theme-specific output mapping, e.g. swamp_enemy -> city_enemy)
- merge_rule_paths: PackedStringArray (theme-specific MergeRule resource paths)
- visuals: Dictionary (background, card_frame, tint) (optional early)
- next_theme_pool: Array[StringName] (optional; controls what appears in 3 boxes)
Notes:
- RNG seed config lives in Main export vars (fixed or system-time)
ThemeChoice mapping:
- Buttons return theme_id (no hardcoded ids)
- Theme selection priority: next_theme_pool (if non-empty) else theme_pool (fallback)
MergeRule loading priority:
- ThemeDef.merge_rule_paths first
- Fallback to Main.merge_rules_path only when theme does not provide paths

## 7.1) Theme pool (runtime)
Fields:
- theme_pool: PackedStringArray (fallback theme ids)
Location:
- Main.theme_pool export var

## 8) Runtime instance (not a Resource)
CardInstance:
- def_id: StringName
- instance_id: int
- state (e.g., placed coords, durability) if needed
Enemy recognition (current runtime rule):
- `String(def_id).ends_with("_enemy")`
- Future recommendation: switch to explicit CardDef kind/enemy flag for stronger typing

## 9) Drop Pool (MVP runtime config)
Fixed list used for enemy drops (not a Resource yet).
Structure:
- drop_pool: PackedStringArray of CardDef ids
Current pool:
- wood_spear
- swamp_spirit
- swamp_mud
XP rules (MVP):
- Trash: +1 XP
- Kill: +3 XP
Placement:
- Drops spawn into OverflowArea (stacked)

## 10) M2 planned runtime contracts
- CombatResolver entrypoint:
  - All boss/enemy HP updates should flow through one resolver function.
  - T14 implementation: `ResolveCombatButton` -> `_on_resolve_combat_pressed()` -> `_resolve_boss_round()`.
  - `ChallengeBossButton` is state transition only (BossReady -> BossFight), no direct damage.
  - DebugDamage remains optional debug-only utility (`debug_damage_enabled`).
- Enemy/type recognition:
  - Target rule: CardDef.kind-based branching.
  - Temporary compatibility may keep suffix-based fallback during migration.
- Data loading:
  - Theme/Card/MergeRule references should be loaded through a single resolver/registry layer.
  - merge_rule_paths (ThemeDef) is preferred; Main fallback path is compatibility-only.
- Validation:
  - Startup checks should validate theme_pool, deck_weights ids, merge_rule_paths, and missing resources.

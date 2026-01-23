# Scene Tree & Signals (baseline)

## Main.tscn
Main (Node)
- Board (Board)
- UI (CanvasLayer)
  - HeroPanel (Control)
  - TrashZone (Control)
  - BossPreview (Control)
  - ThemeChoice (Control) [hidden most of the time]
  - DebugHUD (Control) [optional]

Responsibilities:
- Game state machine: RUNNING -> BOSS -> VICTORY -> THEME_CHOICE -> NEXT_LEVEL
- Own RNG seed and spawn counter
- Coordinates system: board cell size, mapping screen->cell

Signals (suggested):
- board_cell_dropped(card_instance, cell: Vector2i)
- hero_drop(card_instance)
- trash_drop(card_instance)
- merge_happened(input_a, input_b, output)
- combat_started(target_enemy)
- combat_ended(victory: bool)
- boss_spawned(boss_id)
- level_completed
- theme_chosen(theme_id)

## Board.tscn
Board (Control or Node2D)
- GridVisual (Node2D/Control)
- OccupancyLayer (Node) [holds card views]
Responsibilities:
- Convert mouse drop position -> cell coord
- Maintain occupancy map: Dictionary[Vector2i, CardView]
- Provide query for highlight: get_mergeable_partners(card_def_id) -> Array[CardView]

## CardLayer (in Main.tscn UI)
Responsibilities:
- Receives drag release and dispatches to TrashZone > HeroPanel > Board
- Hit-tests visible ColorRect areas for UI drops

## CardView.tscn
CardView (Control)
- TextureRect / Label for name
- (optional) highlight overlay
Responsibilities:
- Drag source
- Holds ref to CardDef id
Signals:
- drag_started(card_view)
- drag_ended(card_view, drop_target_type, drop_data)

## HeroPanel.tscn
HeroPanel (Control)
- Portrait
- Stats labels
- Equipment slots (weapon/armor/trinket)
Responsibilities:
- Accept drops
- Apply equipment bonuses
Signals:
- equip_requested(card_view)
- combat_requested(enemy_card_view)

## TrashZone.tscn
TrashZone (Control)
Responsibilities:
- Accept drops
- Emit delete_requested
Signals:
- delete_requested(card_view)

## BossPreview.tscn
BossPreview (Control)
- Portrait / Name / Skills / Weakness
Responsibilities:
- Display boss data at level start

## ThemeChoice.tscn
ThemeChoice (Control)
- 3 Buttons (BoxA/BoxB/BoxC)
Responsibilities:
- Show 3 theme options
Signals:
- theme_chosen(theme_id)

UI path notes:
- UI/ThemeChoice/VBoxContainer/BoxA
- UI/ThemeChoice/VBoxContainer/BoxB
- UI/ThemeChoice/VBoxContainer/BoxC
- UI/DebugHUD/DebugBossButton (debug only)
- ThemeChoice uses high z_index to stay above cards

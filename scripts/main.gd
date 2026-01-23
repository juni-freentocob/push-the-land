extends Node

@export var theme: ThemeDef
@export var total_spawn: int = 100
@export var use_fixed_seed: bool = true
@export var fixed_seed: int = 12345
@export var merge_rules: Array[MergeRule] = []
@export var merge_rules_path: String = "res://data/merge/swamp_rules.tres"

@onready var board: Board = $Board
@onready var hero_panel: HeroPanel = $UI/HeroPanel
@onready var trash_zone: TrashZone = $UI/TrashZone
@onready var boss_preview: BossPreview = $UI/BossPreview
@onready var theme_choice: ThemeChoice = $UI/ThemeChoice
@onready var card_layer: CardLayer = $UI/CardLayer
@onready var overflow_area: Control = get_node_or_null("UI/OverflowArea") as Control
@onready var seed_label: Label = _find_label("SeedLabel")
@onready var spawn_label: Label = _find_label("SpawnLabel")
@onready var debug_boss_button: Button = _find_button("DebugBossButton")

const CARD_VIEW_SCENE: PackedScene = preload("res://scenes/cards/CardView.tscn")

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var spawned_count: int = 0
var active_seed: int = 0
var boss_spawned: bool = false
var boss_defeated: bool = false

func _ready() -> void:
	if theme == null:
		push_error("[Main] ThemeDef not assigned.")
		return
	var hud := get_node_or_null("UI/DebugHUD") as Control
	if hud != null:
		hud.z_index = 100
	theme_choice.z_index = 200
	_load_merge_rules()
	board.set_merge_rules(merge_rules)
	board.merge_happened.connect(_on_board_merge_happened)
	theme_choice.theme_chosen.connect(_on_theme_chosen)
	if debug_boss_button == null:
		push_error("[Main] DebugBossButton not found. Check UI/DebugHUD/DebugBox/DebugBossButton.")
	else:
		debug_boss_button.pressed.connect(debug_defeat_boss)
	_setup_seed()
	_update_debug_hud()
	_spawn_initial_cards()
	_show_boss_preview()

func _setup_seed() -> void:
	if use_fixed_seed:
		active_seed = fixed_seed
	else:
		active_seed = int(Time.get_unix_time_from_system())
	rng.seed = active_seed

func _load_merge_rules() -> void:
	if not merge_rules.is_empty():
		return
	if merge_rules_path.is_empty():
		push_error("[Main] Merge rules path is empty.")
		return
	var res := load(merge_rules_path)
	if res == null:
		push_error("[Main] Failed to load merge rules: %s" % merge_rules_path)
		return
	merge_rules = [res as MergeRule]

func _spawn_initial_cards() -> void:
	for _i in range(total_spawn):
		_spawn_one()
	_update_debug_hud()
	_try_spawn_boss()

func _try_spawn_boss() -> void:
	if boss_spawned:
		return
	if spawned_count >= total_spawn:
		boss_spawned = true
		print("[Main] Boss spawned (placeholder).")

func _show_boss_preview() -> void:
	boss_preview.show_boss("Swamp King", "Fire", PackedStringArray(["Toxic Breath", "Vine Grasp"]))

func _spawn_one() -> void:
	var card_id := _pick_weighted_id(theme.deck_weights)
	var card_view := CARD_VIEW_SCENE.instantiate() as CardView
	card_layer.add_child(card_view)
	card_view.def_id = card_id
	card_view.drag_started.connect(_on_card_drag_started)
	card_view.drag_ended.connect(_on_card_drag_ended)
	card_view.hover_started.connect(_on_card_hover_started)
	card_view.hover_ended.connect(_on_card_hover_ended)
	var label := card_view.get_node_or_null("Label") as Label
	if label != null:
		label.text = String(card_id)
	_place_spawned_card(card_view, spawned_count)
	spawned_count += 1

func _place_spawned_card(card_view: CardView, index: int) -> void:
	var max_board := board.board_size * board.board_size
	if index < max_board:
		var cell := Vector2i(index % board.board_size, int(index / board.board_size))
		board.place_card_at_cell(card_view, cell)
	else:
		var extra_index := index - max_board
		var pile_offset := Vector2((extra_index % 6) * 6, int(extra_index / 6) * 6)
		_place_in_overflow(card_view, pile_offset)

func _place_in_overflow(card_view: CardView, pile_offset: Vector2) -> void:
	if overflow_area == null:
		card_view.global_position = board.global_position + Vector2(12, 12) + pile_offset
		return
	card_view.reparent(overflow_area)
	card_view.global_position = overflow_area.get_global_rect().position + Vector2(8, 8) + pile_offset

func _pick_weighted_id(weights: Dictionary) -> StringName:
	if weights.is_empty():
		return &""
	var total: int = 0
	for key in weights.keys():
		total += int(weights[key])
	var roll: int = rng.randi_range(1, total)
	var acc: int = 0
	for key in weights.keys():
		acc += int(weights[key])
		if roll <= acc:
			return StringName(key)
	return StringName(weights.keys()[0])

func _update_debug_hud() -> void:
	if seed_label == null or spawn_label == null:
		push_error("[Main] DebugHUD labels missing. Check UI/DebugHUD/DebugBox/SeedLabel + SpawnLabel.")
		return
	seed_label.text = "Seed: %d" % active_seed
	spawn_label.text = "Theme: %s | Spawned: %d/%d" % [theme.display_name, spawned_count, total_spawn]

func _find_label(label_name: String) -> Label:
	var node := get_node_or_null("UI/DebugHUD/DebugBox/%s" % label_name)
	if node == null:
		node = get_node_or_null("UI/DebugHUD/%s" % label_name)
	if node == null:
		var hud := get_node_or_null("UI/DebugHUD")
		if hud != null:
			node = hud.find_child(label_name, true, false)
	return node as Label

func _find_button(button_name: String) -> Button:
	var node := get_node_or_null("UI/DebugHUD/DebugBox/%s" % button_name)
	if node == null:
		node = get_node_or_null("UI/DebugHUD/%s" % button_name)
	if node == null:
		var hud := get_node_or_null("UI/DebugHUD")
		if hud != null:
			node = hud.find_child(button_name, true, false)
	return node as Button

func _on_card_hover_started(card_view: CardView) -> void:
	board.highlight_mergeable(card_view.def_id, card_view)

func _on_card_hover_ended(_card_view: CardView) -> void:
	board.clear_highlights()

func _on_card_drag_started(card_view: CardView) -> void:
	board.set_hover_source(card_view.def_id, card_view)

func _on_card_drag_ended(_card_view: CardView) -> void:
	board.clear_hover_source()

func _on_board_merge_happened(_input_a: StringName, _input_b: StringName, output: StringName, cell: Vector2i) -> void:
	var card_view := CARD_VIEW_SCENE.instantiate() as CardView
	card_layer.add_child(card_view)
	card_view.def_id = output
	card_view.drag_started.connect(_on_card_drag_started)
	card_view.drag_ended.connect(_on_card_drag_ended)
	card_view.hover_started.connect(_on_card_hover_started)
	card_view.hover_ended.connect(_on_card_hover_ended)
	var label := card_view.get_node_or_null("Label") as Label
	if label != null:
		label.text = String(output)
	board.place_card_at_cell(card_view, cell)

func _on_theme_chosen(theme_id: StringName) -> void:
	print("[Main] Theme chosen:", theme_id)
	theme_choice.hide_choices()

func debug_defeat_boss() -> void:
	boss_spawned = true
	if boss_defeated:
		return
	boss_defeated = true
	boss_preview.hide_boss()
	theme_choice.show_choices("Theme A", "Theme B", "Theme C")
	print("[Main] Debug defeat boss triggered.")

extends Node

@export var theme: ThemeDef
@export var total_spawn: int = 100
@export var use_fixed_seed: bool = true
@export var fixed_seed: int = 12345

@onready var board: Board = $Board
@onready var hero_panel: HeroPanel = $UI/HeroPanel
@onready var trash_zone: TrashZone = $UI/TrashZone
@onready var boss_preview: BossPreview = $UI/BossPreview
@onready var theme_choice: ThemeChoice = $UI/ThemeChoice
@onready var card_layer: CardLayer = $UI/CardLayer
@onready var seed_label: Label = get_node_or_null("UI/DebugHUD/DebugBox/SeedLabel") as Label
@onready var spawn_label: Label = get_node_or_null("UI/DebugHUD/DebugBox/SpawnLabel") as Label

const CARD_VIEW_SCENE: PackedScene = preload("res://scenes/cards/CardView.tscn")

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var spawned_count: int = 0
var active_seed: int = 0

func _ready() -> void:
	if theme == null:
		push_error("[Main] ThemeDef not assigned.")
		return
	_setup_seed()
	_update_debug_hud()
	_spawn_initial_cards()

func _setup_seed() -> void:
	if use_fixed_seed:
		active_seed = fixed_seed
	else:
		active_seed = int(Time.get_unix_time_from_system())
	rng.seed = active_seed

func _spawn_initial_cards() -> void:
	for _i in range(total_spawn):
		_spawn_one()
	_update_debug_hud()

func _spawn_one() -> void:
	var card_id := _pick_weighted_id(theme.deck_weights)
	var card_view := CARD_VIEW_SCENE.instantiate() as CardView
	card_layer.add_child(card_view)
	card_view.set_meta("def_id", card_id)
	var label := card_view.get_node_or_null("Label") as Label
	if label != null:
		label.text = String(card_id)
	_place_spawned_card(card_view, spawned_count)
	spawned_count += 1

func _place_spawned_card(card_view: CardView, index: int) -> void:
	var max_board := board.board_size * board.board_size
	if index < max_board:
		var cell := Vector2i(index % board.board_size, int(index / board.board_size))
		card_view.global_position = board.cell_to_global_pos(cell, card_view.size)
	else:
		var extra_index := index - max_board
		var pile_offset := Vector2((extra_index % 6) * 6, int(extra_index / 6) * 6)
		card_view.global_position = board.global_position + Vector2(12, 12) + pile_offset

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

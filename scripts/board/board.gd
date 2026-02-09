class_name Board
extends Control

signal board_cell_dropped(card_view: Node, cell: Vector2i)
signal merge_happened(input_a: StringName, input_b: StringName, output: StringName, cell: Vector2i)
signal spirit_terrain_happened(spirit_id: StringName, terrain_id: StringName, output: StringName, cell: Vector2i)

@export var board_size: int = 9
@export var cell_size: int = 64
@export var hover_debug: bool = true

@onready var occupancy_layer: Control = $OccupancyLayer

var occupancy: Dictionary[Vector2i, CardView] = {}
var merge_rules: Array[MergeRule] = []
var _hover_def_id: StringName = &""
var _hover_locked: bool = false
var _card_def_cache: Dictionary[StringName, CardDef] = {}

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if hover_debug:
		if not _hover_locked:
			_update_hover_highlight()

func can_accept_drop(_card_view: CardView) -> bool:
	return true

func accept_drop(card_view: CardView) -> bool:
	var card_center := card_view.get_global_rect().position + (card_view.size * 0.5)
	var cell := global_pos_to_cell(card_center)
	if not _is_cell_in_bounds(cell):
		print("[Board] Drop rejected (out of bounds):", cell)
		return false
	var existing: CardView = occupancy.get(cell) as CardView
	if existing != null and existing != card_view:
		var existing_def := _get_card_def(existing.def_id)
		var incoming_def := _get_card_def(card_view.def_id)
		if _is_complete_terrain(existing_def) and _is_spirit(incoming_def):
			return _resolve_spirit_terrain(existing, card_view, existing.def_id, card_view.def_id, cell)
		if _is_complete_terrain(incoming_def) and _is_spirit(existing_def):
			return _resolve_spirit_terrain(existing, card_view, existing.def_id, card_view.def_id, cell)
		var rule := _find_merge_rule(card_view.def_id, existing.def_id)
		if rule != null:
			return _resolve_merge(existing, card_view, rule, cell)
		print("[Board] Drop rejected (occupied):", cell)
		return false
	_remove_card_from_occupancy(card_view)
	occupancy[cell] = card_view
	card_view.reparent(occupancy_layer)
	card_view.global_position = cell_to_global_pos(cell, card_view.size)
	print("[Board] Drop accepted (cell):", cell)
	return true

func cell_to_global_pos(cell: Vector2i, card_size: Vector2) -> Vector2:
	var board_origin := get_global_rect().position
	var cell_origin := board_origin + Vector2(cell.x * cell_size, cell.y * cell_size)
	var cell_center := cell_origin + Vector2(cell_size * 0.5, cell_size * 0.5)
	return cell_center - (card_size * 0.5)

func global_pos_to_cell(global_pos: Vector2) -> Vector2i:
	var board_origin := get_global_rect().position
	var local := global_pos - board_origin
	return Vector2i(floor(local.x / cell_size), floor(local.y / cell_size))

func _is_cell_in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < board_size and cell.y < board_size

func _remove_card_from_occupancy(card_view: CardView) -> void:
	var to_remove: Vector2i = Vector2i(-1, -1)
	for cell: Vector2i in occupancy.keys():
		if occupancy[cell] == card_view:
			to_remove = cell
			break
	if to_remove.x != -1:
		occupancy.erase(to_remove)

func remove_card(card_view: CardView) -> void:
	_remove_card_from_occupancy(card_view)

func clear_occupancy() -> void:
	occupancy.clear()

func set_merge_rules(rules: Array[MergeRule]) -> void:
	merge_rules = []
	for rule in rules:
		if rule != null:
			merge_rules.append(rule)

func place_card_at_cell(card_view: CardView, cell: Vector2i) -> void:
	occupancy[cell] = card_view
	card_view.reparent(occupancy_layer)
	card_view.global_position = cell_to_global_pos(cell, card_view.size)

func highlight_mergeable(def_id: StringName, exclude: CardView = null) -> void:
	for cell: Vector2i in occupancy.keys():
		var other := occupancy[cell]
		if other == null:
			continue
		if exclude != null and other == exclude:
			other.set_highlighted(false)
			continue
		var can_merge := _can_trigger_interaction(def_id, other.def_id)
		other.set_highlighted(can_merge)

func clear_highlights() -> void:
	for cell: Vector2i in occupancy.keys():
		var other := occupancy[cell]
		if other != null:
			other.set_highlighted(false)
	_hover_def_id = &""

func set_hover_source(def_id: StringName, exclude: CardView = null) -> void:
	_hover_locked = true
	_hover_def_id = def_id
	highlight_mergeable(def_id, exclude)

func clear_hover_source() -> void:
	_hover_locked = false
	clear_highlights()

func _find_merge_rule(id_a: StringName, id_b: StringName) -> MergeRule:
	for rule in merge_rules:
		if rule == null:
			continue
		if _rule_matches(rule, id_a, id_b):
			return rule
	return null

func _can_trigger_interaction(id_a: StringName, id_b: StringName) -> bool:
	if _find_merge_rule(id_a, id_b) != null:
		return true
	var def_a := _get_card_def(id_a)
	var def_b := _get_card_def(id_b)
	if def_a == null or def_b == null:
		return false
	return (_is_complete_terrain(def_a) and _is_spirit(def_b)) or (_is_complete_terrain(def_b) and _is_spirit(def_a))

func _rule_matches(rule: MergeRule, id_a: StringName, id_b: StringName) -> bool:
	if rule.inputs.size() != 2:
		return false
	var a := String(id_a)
	var b := String(id_b)
	if a == "" or b == "":
		return false
	if a == b:
		return rule.inputs[0] == a and rule.inputs[1] == a
	return rule.inputs.has(a) and rule.inputs.has(b)

func _resolve_merge(existing: CardView, incoming: CardView, rule: MergeRule, cell: Vector2i) -> bool:
	_remove_card_from_occupancy(existing)
	_remove_card_from_occupancy(incoming)
	existing.queue_free()
	incoming.queue_free()
	merge_happened.emit(existing.def_id, incoming.def_id, rule.output, cell)
	return true

func _resolve_spirit_terrain(existing: CardView, incoming: CardView, existing_id: StringName, incoming_id: StringName, cell: Vector2i) -> bool:
	var spirit_id: StringName = &""
	var terrain_id: StringName = &""
	var existing_def := _get_card_def(existing_id)
	var incoming_def := _get_card_def(incoming_id)
	if _is_spirit(existing_def):
		spirit_id = existing_id
	elif _is_spirit(incoming_def):
		spirit_id = incoming_id
	if _is_complete_terrain(existing_def):
		terrain_id = existing_id
	elif _is_complete_terrain(incoming_def):
		terrain_id = incoming_id
	_remove_card_from_occupancy(existing)
	_remove_card_from_occupancy(incoming)
	existing.queue_free()
	incoming.queue_free()
	spirit_terrain_happened.emit(spirit_id, terrain_id, &"swamp_enemy", cell)
	return true

func _get_card_def(card_id: StringName) -> CardDef:
	if card_id == &"":
		return null
	if _card_def_cache.has(card_id):
		return _card_def_cache[card_id]
	var path := "res://data/cards/%s.tres" % String(card_id)
	var res := load(path)
	var def := res as CardDef
	if def != null:
		_card_def_cache[card_id] = def
	return def

func _is_complete_terrain(def: CardDef) -> bool:
	if def == null:
		return false
	if def.kind != CardDef.CardKind.TERRAIN_PART:
		return false
	return bool(def.stats.get("complete_terrain", false))

func _is_spirit(def: CardDef) -> bool:
	if def == null:
		return false
	return def.kind == CardDef.CardKind.SPIRIT

func _update_hover_highlight() -> void:
	var mouse_pos := get_viewport().get_mouse_position()
	if not get_global_rect().has_point(mouse_pos):
		if _hover_def_id != &"":
			clear_highlights()
		return
	var cell := global_pos_to_cell(mouse_pos)
	var hovered: CardView = occupancy.get(cell) as CardView
	var new_def_id := hovered.def_id if hovered != null else &""
	if new_def_id == _hover_def_id:
		return
	_hover_def_id = new_def_id
	if _hover_def_id == &"":
		clear_highlights()
	else:
		highlight_mergeable(_hover_def_id)

func debug_drop(card_view: Node, cell: Vector2i) -> void:
	print("[Board] Drop request:", card_view, "cell:", cell)
	board_cell_dropped.emit(card_view, cell)

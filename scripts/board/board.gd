class_name Board
extends Control

signal board_cell_dropped(card_view: Node, cell: Vector2i)

@export var board_size: int = 9
@export var cell_size: int = 64

@onready var occupancy_layer: Control = $OccupancyLayer

var occupancy: Dictionary[Vector2i, CardView] = {}

func _ready() -> void:
	pass

func can_accept_drop(_card_view: CardView) -> bool:
	return true

func accept_drop(card_view: CardView) -> bool:
	var cell := global_pos_to_cell(get_viewport().get_mouse_position())
	if not _is_cell_in_bounds(cell):
		print("[Board] Drop rejected (out of bounds):", cell)
		return false
	var existing: CardView = occupancy.get(cell) as CardView
	if existing != null and existing != card_view:
		print("[Board] Drop rejected (occupied):", cell)
		return false
	_remove_card_from_occupancy(card_view)
	occupancy[cell] = card_view
	card_view.reparent(occupancy_layer)
	card_view.global_position = cell_to_global_pos(cell, card_view.size)
	print("[Board] Drop accepted (cell):", cell)
	return true

func cell_to_global_pos(cell: Vector2i, card_size: Vector2) -> Vector2:
	var cell_origin := global_position + Vector2(cell.x * cell_size, cell.y * cell_size)
	var cell_center := cell_origin + Vector2(cell_size * 0.5, cell_size * 0.5)
	return cell_center - (card_size * 0.5)

func global_pos_to_cell(global_pos: Vector2) -> Vector2i:
	var local := global_pos - global_position
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

func debug_drop(card_view: Node, cell: Vector2i) -> void:
	print("[Board] Drop request:", card_view, "cell:", cell)
	board_cell_dropped.emit(card_view, cell)

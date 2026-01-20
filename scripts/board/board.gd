class_name Board
extends Control

signal board_cell_dropped(card_view: Node, cell: Vector2i)

func _ready() -> void:
	print("[Board] Ready")

func debug_drop(card_view: Node, cell: Vector2i) -> void:
	print("[Board] Drop request:", card_view, "cell:", cell)
	board_cell_dropped.emit(card_view, cell)

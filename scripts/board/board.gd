class_name Board
extends Control

signal board_cell_dropped(card_view: Node, cell: Vector2i)

func _ready() -> void:
	pass

func can_accept_drop(_card_view: CardView) -> bool:
	return true

func accept_drop(card_view: CardView) -> void:
	print("[Board] Drop accepted (layer):", card_view)

func debug_drop(card_view: Node, cell: Vector2i) -> void:
	print("[Board] Drop request:", card_view, "cell:", cell)
	board_cell_dropped.emit(card_view, cell)

class_name TrashZone
extends Control

signal delete_requested(card_view: Node)

func _ready() -> void:
	pass

func accept_drop(card_view: CardView) -> void:
	print("[TrashZone] Drop accepted (layer):", card_view)
	delete_requested.emit(card_view)

func can_accept_drop(_card_view: CardView) -> bool:
	return true

func debug_delete(card_view: Node) -> void:
	delete_requested.emit(card_view)

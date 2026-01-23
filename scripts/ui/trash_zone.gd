class_name TrashZone
extends Control

signal delete_requested(card_view: CardView)

func _ready() -> void:
	pass

func accept_drop(card_view: CardView) -> void:
	delete_requested.emit(card_view)

func can_accept_drop(_card_view: CardView) -> bool:
	return true

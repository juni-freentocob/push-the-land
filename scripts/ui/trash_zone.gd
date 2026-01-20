class_name TrashZone
extends Control

signal delete_requested(card_view: Node)

func _ready() -> void:
	print("[TrashZone] Ready")

func debug_delete(card_view: Node) -> void:
	print("[TrashZone] Delete requested:", card_view)
	delete_requested.emit(card_view)

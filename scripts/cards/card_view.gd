class_name CardView
extends Control

signal drag_started(card_view: Node)
signal drag_ended(card_view: Node)

func _ready() -> void:
	print("[CardView] Ready")

func debug_drag_start() -> void:
	print("[CardView] Drag started")
	drag_started.emit(self)

func debug_drag_end() -> void:
	print("[CardView] Drag ended")
	drag_ended.emit(self)

class_name CardLayer
extends Control

@onready var hero_panel: HeroPanel = get_parent().get_node("HeroPanel")
@onready var hero_area: Control = hero_panel.get_node("ColorRect")
@onready var trash_zone: TrashZone = get_parent().get_node("TrashZone")
@onready var trash_area: Control = trash_zone.get_node("ColorRect")
@onready var board: Board = get_parent().get_parent().get_node("Board")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

func handle_drop_from_card(card_view: CardView) -> bool:
	var mouse_pos := get_viewport().get_mouse_position()
	if trash_area.get_global_rect().has_point(mouse_pos) and trash_zone.can_accept_drop(card_view):
		trash_zone.accept_drop(card_view)
		return true
	if hero_area.get_global_rect().has_point(mouse_pos) and hero_panel.can_accept_drop(card_view):
		hero_panel.accept_drop(card_view)
		return true
	if board.get_global_rect().has_point(mouse_pos) and board.can_accept_drop(card_view):
		board.accept_drop(card_view)
		return true
	return false

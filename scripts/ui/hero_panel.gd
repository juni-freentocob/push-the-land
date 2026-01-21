class_name HeroPanel
extends Control

signal equip_requested(card_view: Node)
signal combat_requested(enemy_card_view: Node)

func _ready() -> void:
	pass

func accept_drop(card_view: CardView) -> void:
	print("[HeroPanel] Drop accepted (layer):", card_view)
	equip_requested.emit(card_view)

func can_accept_drop(_card_view: CardView) -> bool:
	return true

func debug_equip(card_view: Node) -> void:
	equip_requested.emit(card_view)

func debug_combat(enemy_card_view: Node) -> void:
	combat_requested.emit(enemy_card_view)

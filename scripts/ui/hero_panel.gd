class_name HeroPanel
extends Control

signal equip_requested(card_view: Node)
signal combat_requested(enemy_card_view: Node)

func _ready() -> void:
	print("[HeroPanel] Ready")

func debug_equip(card_view: Node) -> void:
	print("[HeroPanel] Equip requested:", card_view)
	equip_requested.emit(card_view)

func debug_combat(enemy_card_view: Node) -> void:
	print("[HeroPanel] Combat requested:", enemy_card_view)
	combat_requested.emit(enemy_card_view)

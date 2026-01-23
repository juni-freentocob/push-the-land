class_name HeroPanel
extends Control

signal equip_requested(card_view: CardView)
signal combat_requested(enemy_card_view: CardView)

@export var base_hp: int = 10
@export var base_atk: int = 2
@export var base_def: int = 0

@onready var hp_label: Label = $HpLabel
@onready var atk_label: Label = $AtkLabel
@onready var def_label: Label = $DefLabel
@onready var xp_label: Label = $XpLabel

var hp: int = 0
var atk: int = 0
var defense: int = 0
var xp: int = 0

func _ready() -> void:
	hp = base_hp
	atk = base_atk
	defense = base_def
	xp = 0
	_update_labels()

func accept_drop(card_view: CardView) -> void:
	if card_view.def_id == &"swamp_enemy":
		combat_requested.emit(card_view)
	else:
		equip_requested.emit(card_view)

func can_accept_drop(_card_view: CardView) -> bool:
	return true

func apply_equipment_bonus(stats: Dictionary) -> void:
	atk += int(stats.get("atk_bonus", 0))
	defense += int(stats.get("def_bonus", 0))
	hp += int(stats.get("hp_bonus", 0))
	_update_labels()

func apply_damage(amount: int) -> void:
	hp = max(hp - amount, 0)
	_update_labels()

func add_xp(amount: int) -> void:
	xp += amount
	_update_labels()

func get_attack() -> int:
	return atk

func get_defense() -> int:
	return defense

func _update_labels() -> void:
	hp_label.text = "HP: %d" % hp
	atk_label.text = "ATK: %d" % atk
	def_label.text = "DEF: %d" % defense
	xp_label.text = "XP: %d" % xp

class_name BossPreview
extends Control

@onready var name_label: Label = $NameLabel
@onready var weakness_label: Label = $WeaknessLabel
@onready var skills_label: Label = $SkillsLabel

func show_boss(name_text: String, weakness: String, skills: PackedStringArray) -> void:
	visible = true
	name_label.text = "Boss: %s" % name_text
	weakness_label.text = "Weakness: %s" % weakness
	skills_label.text = "Skills: %s" % ", ".join(skills)

func hide_boss() -> void:
	visible = false

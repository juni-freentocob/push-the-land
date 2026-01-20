class_name ThemeChoice
extends Control

signal theme_chosen(theme_id: StringName)

func _ready() -> void:
	print("[ThemeChoice] Ready (visible=%s)" % self.visible)

func debug_choose(theme_id: StringName) -> void:
	print("[ThemeChoice] Theme chosen:", theme_id)
	theme_chosen.emit(theme_id)

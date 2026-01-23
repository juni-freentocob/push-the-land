class_name ThemeChoice
extends Control

signal theme_chosen(theme_id: StringName)

@onready var box_a: Button = get_node_or_null("VBoxContainer/BoxA") as Button
@onready var box_b: Button = get_node_or_null("VBoxContainer/BoxB") as Button
@onready var box_c: Button = get_node_or_null("VBoxContainer/BoxC") as Button

func _ready() -> void:
	visible = false
	if box_a == null or box_b == null or box_c == null:
		push_error("[ThemeChoice] Missing BoxA/BoxB/BoxC buttons.")
		return
	box_a.pressed.connect(func(): _choose(&"theme_a"))
	box_b.pressed.connect(func(): _choose(&"theme_b"))
	box_c.pressed.connect(func(): _choose(&"theme_c"))

func show_choices(a: String, b: String, c: String) -> void:
	if box_a == null or box_b == null or box_c == null:
		return
	visible = true
	box_a.text = a
	box_b.text = b
	box_c.text = c

func hide_choices() -> void:
	visible = false

func _choose(theme_id: StringName) -> void:
	emit_signal("theme_chosen", theme_id)

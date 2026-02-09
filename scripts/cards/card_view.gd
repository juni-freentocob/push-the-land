class_name CardView
extends Control

signal drag_started(card_view: Node)
signal drag_ended(card_view: Node)
signal hover_started(card_view: CardView)
signal hover_ended(card_view: CardView)

var def_id: StringName = &""
var interaction_enabled: bool = true

var _dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO
var _start_pos: Vector2 = Vector2.ZERO
var _prev_z_index: int = 0
var _prev_z_relative: bool = true
var _prev_top_level: bool = false

@onready var highlight: Control = get_node_or_null("Highlight") as Control

func _ready() -> void:
	add_to_group("card_view")
	if highlight != null:
		highlight.visible = false
		highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
		highlight.z_index = 10
		highlight.set_anchors_preset(Control.PRESET_FULL_RECT)

func _gui_input(event: InputEvent) -> void:
	if not interaction_enabled:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_dragging = true
			_start_pos = global_position
			_drag_offset = get_global_mouse_position() - global_position
			_prev_z_index = z_index
			_prev_z_relative = z_as_relative
			_prev_top_level = is_set_as_top_level()
			set_as_top_level(true)
			z_as_relative = false
			z_index = 1000
			drag_started.emit(self)
			move_to_front()
			get_viewport().set_input_as_handled()
		elif _dragging:
			_dragging = false
			z_index = _prev_z_index
			z_as_relative = _prev_z_relative
			set_as_top_level(_prev_top_level)
			drag_ended.emit(self)
			var accepted := false
			var card_layer := _find_card_layer()
			if card_layer != null:
				accepted = card_layer.handle_drop_from_card(self)
			if not accepted:
				global_position = _start_pos

func _process(_delta: float) -> void:
	if _dragging:
		global_position = get_global_mouse_position() - _drag_offset

func _mouse_entered() -> void:
	if not interaction_enabled:
		return
	hover_started.emit(self)

func _mouse_exited() -> void:
	if not interaction_enabled:
		return
	hover_ended.emit(self)

func reset_drag_state() -> void:
	_dragging = false
	z_index = _prev_z_index
	z_as_relative = _prev_z_relative
	set_as_top_level(_prev_top_level)

func set_highlighted(enabled: bool) -> void:
	if highlight != null:
		highlight.visible = enabled

func _find_card_layer() -> Node:
	var node := get_parent()
	while node != null:
		if node.has_method("handle_drop_from_card"):
			return node
		node = node.get_parent()
	var root := get_tree().root
	if root == null:
		return null
	var found := root.find_child("CardLayer", true, false)
	if found != null and found.has_method("handle_drop_from_card"):
		return found
	return null

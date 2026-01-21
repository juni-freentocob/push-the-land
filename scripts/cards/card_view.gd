class_name CardView
extends Control

signal drag_started(card_view: Node)
signal drag_ended(card_view: Node)

var _dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO
var _start_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	pass

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_dragging = true
			_start_pos = global_position
			_drag_offset = get_global_mouse_position() - global_position
			drag_started.emit(self)
			move_to_front()
			get_viewport().set_input_as_handled()
		elif _dragging:
			_dragging = false
			drag_ended.emit(self)
			var layer := get_parent()
			var accepted := false
			if layer != null and layer.has_method("handle_drop_from_card"):
				accepted = layer.handle_drop_from_card(self)
			if not accepted:
				global_position = _start_pos

func _process(_delta: float) -> void:
	if _dragging:
		global_position = get_global_mouse_position() - _drag_offset

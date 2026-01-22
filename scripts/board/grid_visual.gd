class_name GridVisual
extends Control

@export var line_color: Color = Color(0.8, 0.8, 0.8, 0.35)
@export var border_color: Color = Color(1, 1, 1, 0.6)
@export var hover_color: Color = Color(1, 1, 0, 0.18)

@onready var board: Board = get_parent()

var _last_hover_cell: Vector2i = Vector2i(-999, -999)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func _process(_delta: float) -> void:
	var cell := _mouse_cell()
	if cell != _last_hover_cell:
		_last_hover_cell = cell
		queue_redraw()

func _draw() -> void:
	if board == null:
		return
	var size_px := Vector2(board.board_size * board.cell_size, board.board_size * board.cell_size)
	_draw_grid(size_px)
	_draw_border(size_px)
	_draw_hover(size_px)

func _draw_grid(size_px: Vector2) -> void:
	for i in range(1, board.board_size):
		var x := float(i * board.cell_size)
		draw_line(Vector2(x, 0), Vector2(x, size_px.y), line_color, 1.0)
		var y := float(i * board.cell_size)
		draw_line(Vector2(0, y), Vector2(size_px.x, y), line_color, 1.0)

func _draw_border(size_px: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, size_px), border_color, false, 2.0)

func _draw_hover(_size_px: Vector2) -> void:
	var cell := _last_hover_cell
	if cell.x < 0 or cell.y < 0 or cell.x >= board.board_size or cell.y >= board.board_size:
		return
	var rect := Rect2(
		Vector2(cell.x * board.cell_size, cell.y * board.cell_size),
		Vector2(board.cell_size, board.cell_size)
	)
	draw_rect(rect, hover_color, true)

func _mouse_cell() -> Vector2i:
	if board == null:
		return Vector2i(-999, -999)
	var local := board.get_local_mouse_position()
	return Vector2i(floor(local.x / board.cell_size), floor(local.y / board.cell_size))

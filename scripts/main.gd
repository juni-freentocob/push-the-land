extends Node

@onready var board: Board = $Board
@onready var hero_panel: HeroPanel = $UI/HeroPanel
@onready var trash_zone: TrashZone = $UI/TrashZone
@onready var boss_preview: BossPreview = $UI/BossPreview
@onready var theme_choice: ThemeChoice = $UI/ThemeChoice

func _ready() -> void:
	print("[Main] Ready")
	print("[Main] Board:", board)
	print("[Main] HeroPanel:", hero_panel)
	print("[Main] TrashZone:", trash_zone)
	print("[Main] BossPreview:", boss_preview)
	print("[Main] ThemeChoice:", theme_choice)

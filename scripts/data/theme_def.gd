class_name ThemeDef
extends Resource

@export var id: StringName
@export var display_name: String = ""
@export var deck_weights: Dictionary = {}
@export var boss_id: StringName = &""
@export var output_remap: Dictionary = {}
@export var merge_rule_paths: PackedStringArray = []
@export var visuals: Dictionary = {}
@export var next_theme_pool: PackedStringArray = []

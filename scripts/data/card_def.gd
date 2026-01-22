class_name CardDef
extends Resource

enum CardKind {
	TERRAIN_PART,
	SPIRIT,
	EQUIPMENT,
	JUNK,
	GENERATED_ENEMY
}

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY
}

enum EquipmentSlot {
	NONE,
	WEAPON,
	ARMOR,
	TRINKET
}

enum SpiritTier {
	NORMAL,
	ELITE
}

@export var id: StringName
@export var display_name: String = ""
@export var kind: CardKind = CardKind.TERRAIN_PART
@export var rarity: Rarity = Rarity.COMMON
@export var theme_tags: PackedStringArray = []
@export var stackable: bool = false
@export var equipment_slot: EquipmentSlot = EquipmentSlot.NONE
@export var stats: Dictionary = {}
@export var terrain_part: StringName = &""
@export var spirit_tier: SpiritTier = SpiritTier.NORMAL

# HerbData - Resource class for herb items
extends Resource
class_name HerbData

@export var herb_id: String = ""
@export var name_cn: String = ""
@export var tier: int = 1
@export var temperature: String = "neutral"
@export var toxicity: float = 0.0
@export var spirit_power: int = 0
@export var element: String = ""
@export var tags: Array[String] = []
@export var base_price: int = 10
@export var rarity: String = "common"
@export_multiline var lore: String = ""

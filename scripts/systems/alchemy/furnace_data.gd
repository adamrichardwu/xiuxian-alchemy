# FurnaceData - Resource class for furnaces
extends Resource
class_name FurnaceData

@export var furnace_id: String = ""
@export var name_cn: String = ""
@export var quality_bonus: float = 1.0
@export var impurity_modifier: float = 1.0
@export var required_realm: int = 0
@export_multiline var description: String = ""

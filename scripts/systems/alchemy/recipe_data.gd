# RecipeData - Resource class for pill recipes
extends Resource
class_name RecipeData

@export var recipe_id: String = ""
@export var name_cn: String = ""
@export var tier: int = 1
@export var required_realm: int = 0
@export_multiline var description: String = ""
@export var ideal_herbs: Array[String] = []
@export var ideal_fire_curve: String = "gentle_rise"
@export_multiline var fire_description: String = ""
@export_multiline var hidden_tip: String = ""
@export var incomplete: bool = false
@export var forbidden: bool = false

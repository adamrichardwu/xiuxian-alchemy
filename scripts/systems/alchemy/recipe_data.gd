# RecipeData - Pill recipe data class
extends Resource
@export var recipe_id: String = ""
@export var name_cn: String = ""
@export var target_tier: int = 1
@export var required_realm: int = 0
@export var ideal_herbs: Array[String] = []
@export var ideal_fire_curve: String = ""
@export var is_forbidden: bool = false

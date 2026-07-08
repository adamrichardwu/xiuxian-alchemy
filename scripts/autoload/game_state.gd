# GameState - Global state singleton
extends Node

var current_day: int = 1
var realm: int = 0
var dao_insight: float = 0.0
var route_scores: Dictionary = {}
var route_flags: Dictionary = {}
var inventory: Array[String] = []
var known_recipes: Array[String] = []
var completed_commissions: Array[String] = []
var story_flags: Dictionary = {}
var character_relationships: Dictionary = {}
var current_chapter: int = 1
var furnace_id: String = ""

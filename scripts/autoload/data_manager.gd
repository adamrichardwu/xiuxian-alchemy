# DataManager - JSON data loader singleton
extends Node

var herbs: Dictionary = {}
var recipes: Dictionary = {}
var commissions: Dictionary = {}
var events: Dictionary = {}
var realms: Dictionary = {}
var characters: Dictionary = {}
var route_weights: Dictionary = {}

func _ready():
	_load_all_data()

func _load_all_data():
	pass  # TODO: Implement JSON loading

func get_herb(id: String) -> Dictionary:
	return herbs.get(id, {})

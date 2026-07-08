# DataManager - JSON data loader singleton (autoload)
extends Node

# Cached data dictionaries
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
	herbs = _load_json("res://resources/data/herbs.json")
	recipes = _load_json("res://resources/data/recipes.json")
	commissions = _load_json("res://resources/data/commissions.json")
	events = _load_json("res://resources/data/events.json")
	realms = _load_json("res://resources/data/realms.json")
	characters = _load_json("res://resources/data/characters.json")
	route_weights = _load_json("res://resources/data/route_weights.json")
	print("DataManager: All data loaded (%d herbs, %d recipes, %d commissions)" % [
		herbs.get("herbs", []).size(),
		recipes.get("recipes", []).size(),
		commissions.get("commissions", []).size()
	])

func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("DataManager: File not found: " + path)
		return {}
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("DataManager: Cannot open: " + path)
		return {}
	var text = file.get_as_text()
	file.close()
	var json = JSON.new()
	var error = json.parse(text)
	if error != OK:
		push_error("DataManager: JSON parse error in %s: %s" % [path, json.get_error_message()])
		return {}
	return json.get_data()

# --- Herb access ---

func get_herb(id: String) -> Dictionary:
	for herb in herbs.get("herbs", []):
		if herb.get("id") == id:
			return herb
	return {}

func get_all_herbs() -> Array:
	return herbs.get("herbs", [])

func get_herbs_for_realm(realm_index: int) -> Array:
	var realm_names = ["QI_REFINING", "FOUNDATION", "GOLDEN_CORE"]
	var realm_key = realm_names[min(realm_index, realm_names.size() - 1)]
	var result: Array = []
	for herb in herbs.get("herbs", []):
		var vis = herb.get("realm_visibility", {}).get(realm_key, {})
		if vis.get("accuracy", "none") != "none":
			result.append(herb)
	return result

# --- Recipe access ---

func get_recipe(id: String) -> Dictionary:
	for recipe in recipes.get("recipes", []):
		if recipe.get("id") == id:
			return recipe
	return {}

func get_all_recipes() -> Array:
	return recipes.get("recipes", [])

func get_recipes_for_realm(realm_index: int) -> Array:
	var result: Array = []
	for recipe in recipes.get("recipes", []):
		if recipe.get("required_realm", 0) <= realm_index:
			result.append(recipe)
	return result

# --- Commission access ---

func get_commission(id: String) -> Dictionary:
	for comm in commissions.get("commissions", []):
		if comm.get("id") == id:
			return comm
	return {}

func get_commissions_for_day(day: int, realm_index: int) -> Array:
	var result: Array = []
	for comm in commissions.get("commissions", []):
		if comm.get("day", 999) <= day and comm.get("required_realm", 0) <= realm_index:
			if not GameState.completed_commissions.has(comm.get("id")):
				result.append(comm)
	return result

# --- Realm access ---

func get_realm(index: int) -> Dictionary:
	for realm in realms.get("realms", []):
		if realm.get("index") == index:
			return realm
	return {}

func get_all_realms() -> Array:
	return realms.get("realms", [])

# --- Character access ---

func get_character(id: String) -> Dictionary:
	for char in characters.get("characters", []):
		if char.get("id") == id:
			return char
	return {}

# --- Route weight access ---

func get_route_weight(choice_id: String) -> Dictionary:
	for rw in route_weights.get("route_weights", []):
		if rw.get("choice_id") == choice_id:
			return rw
	return {"orthodox": 0, "cthulhu": 0, "meta": 0}

# --- Event access ---

func get_events_for_trigger(trigger: String) -> Array:
	var result: Array = []
	for ev in events.get("events", []):
		if ev.get("trigger", "") == trigger:
			result.append(ev)
	return result

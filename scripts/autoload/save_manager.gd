# SaveManager - Save/Load singleton (autoload)
extends Node

const SAVE_DIR = "user://saves/"
const SAVE_PREFIX = "save_slot_"
const SAVE_EXT = ".json"
const MAX_SLOTS = 5

func _ready():
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)

func save(slot: int) -> bool:
	if slot < 0 or slot >= MAX_SLOTS:
		push_error("SaveManager: Invalid slot %d" % slot)
		return false
	
	var data = {
		"version": 1,
		"current_day": GameState.current_day,
		"current_chapter": GameState.current_chapter,
		"realm": GameState.realm,
		"dao_insight": GameState.dao_insight,
		"pills_brewed_total": GameState.pills_brewed_total,
		"flawless_pills": GameState.flawless_pills,
		"pills_by_tier": GameState.pills_by_tier,
		"herb_inventory": GameState.herb_inventory,
		"known_recipes": GameState.known_recipes,
		"furnace_id": GameState.furnace_id,
		"route_scores": GameState.route_scores,
		"route_flags": GameState.route_flags,
		"completed_commissions": GameState.completed_commissions,
		"story_flags": GameState.story_flags,
		"character_relationships": GameState.character_relationships,
		"active_commission_id": GameState.active_commission_id
	}
	
	var path = SAVE_DIR + SAVE_PREFIX + "%02d" % slot + SAVE_EXT
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: Cannot write to " + path)
		return false
	
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	print("SaveManager: Saved to slot %d" % slot)
	return true

func load(slot: int) -> bool:
	if slot < 0 or slot >= MAX_SLOTS:
		return false
	
	var path = SAVE_DIR + SAVE_PREFIX + "%02d" % slot + SAVE_EXT
	if not FileAccess.file_exists(path):
		return false
	
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	
	var text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(text)
	if error != OK:
		push_error("SaveManager: Corrupted save file")
		return false
	
	var data = json.get_data()
	_apply_data(data)
	print("SaveManager: Loaded from slot %d (day %d)" % [slot, data.get("current_day", 0)])
	return true

func _apply_data(data: Dictionary):
	GameState.current_day = data.get("current_day", 1)
	GameState.current_chapter = data.get("current_chapter", 1)
	GameState.realm = data.get("realm", 0)
	GameState.dao_insight = data.get("dao_insight", 0.0)
	GameState.pills_brewed_total = data.get("pills_brewed_total", 0)
	GameState.flawless_pills = data.get("flawless_pills", 0)
	GameState.pills_by_tier = data.get("pills_by_tier", {})
	GameState.herb_inventory = data.get("herb_inventory", {})
	GameState.known_recipes = data.get("known_recipes", [])
	GameState.furnace_id = data.get("furnace_id", "copper_furnace")
	GameState.route_scores = data.get("route_scores", {"orthodox": 0, "cthulhu": 0, "meta": 0})
	GameState.route_flags = data.get("route_flags", {})
	GameState.completed_commissions = data.get("completed_commissions", [])
	GameState.story_flags = data.get("story_flags", {})
	GameState.character_relationships = data.get("character_relationships", {})
	GameState.active_commission_id = data.get("active_commission_id", "")

func get_save_info(slot: int) -> Dictionary:
	var path = SAVE_DIR + SAVE_PREFIX + "%02d" % slot + SAVE_EXT
	if not FileAccess.file_exists(path):
		return {"exists": false}
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"exists": false}
	var text = file.get_as_text()
	file.close()
	var json = JSON.new()
	json.parse(text)
	var data = json.get_data()
	var realm_data = DataManager.get_realm(data.get("realm", 0))
	return {
		"exists": true,
		"day": data.get("current_day", 1),
		"realm_name": realm_data.get("name_cn", "??"),
		"route": _dominant_route(data.get("route_scores", {}))
	}

func _dominant_route(scores: Dictionary) -> String:
	var s = [scores.get("orthodox", 0), scores.get("cthulhu", 0), scores.get("meta", 0)]
	var names = ["仙道", "禁忌", "觉醒"]
	var max_idx = 0
	for i in range(1, 3):
		if s[i] > s[max_idx]:
			max_idx = i
	return names[max_idx] if s[max_idx] > 0 else "未定"

# GameState - Global state singleton (autoload)
extends Node

# Core state
var current_day: int = 1
var current_chapter: int = 1

# Realm
var realm: int = 0  # CultivationRealm enum index
var dao_insight: float = 0.0
var pills_brewed_total: int = 0
var flawless_pills: int = 0
var pills_by_tier: Dictionary = {}  # {tier: count}

# Inventory
var herb_inventory: Dictionary = {}  # {herb_id: count}
var known_recipes: Array[String] = []
var furnace_id: String = "copper_furnace"

# Route tracking
var route_scores: Dictionary = {"orthodox": 0, "cthulhu": 0, "meta": 0}
var route_flags: Dictionary = {}

# Story state
var completed_commissions: Array[String] = []
var story_flags: Dictionary = {}
var character_relationships: Dictionary = {}
var active_commission_id: String = ""

# Recent brew results (for UI display)
var last_brew_result: Dictionary = {}

func add_herb(herb_id: String, amount: int = 1):
	herb_inventory[herb_id] = herb_inventory.get(herb_id, 0) + amount

func remove_herb(herb_id: String, amount: int = 1) -> bool:
	var current = herb_inventory.get(herb_id, 0)
	if current < amount:
		return false
	herb_inventory[herb_id] = current - amount
	if herb_inventory[herb_id] <= 0:
		herb_inventory.erase(herb_id)
	return true

func has_herbs(requirements: Dictionary) -> bool:
	for herb_id in requirements:
		var needed = requirements[herb_id]
		if herb_inventory.get(herb_id, 0) < needed:
			return false
	return true

func add_dao_insight(amount: float):
	dao_insight = min(dao_insight + amount, 1.0)
	EventBus.dao_insight_changed.emit(dao_insight)

func record_brew(tier: int, is_flawless: bool):
	pills_brewed_total += 1
	pills_by_tier[tier] = pills_by_tier.get(tier, 0) + 1
	if is_flawless:
		flawless_pills += 1

func set_flag(flag: String):
	story_flags[flag] = true
	EventBus.story_flag_set.emit(flag)

func has_flag(flag: String) -> bool:
	return story_flags.get(flag, false)

func reset_for_new_game():
	current_day = 1
	current_chapter = 1
	realm = 0
	dao_insight = 0.0
	pills_brewed_total = 0
	flawless_pills = 0
	pills_by_tier = {}
	herb_inventory = {}
	known_recipes = ["qi_replenishing_pill"]
	furnace_id = "copper_furnace"
	route_scores = {"orthodox": 0, "cthulhu": 0, "meta": 0}
	route_flags = {}
	completed_commissions = []
	story_flags = {}
	character_relationships = {}
	active_commission_id = ""
	last_brew_result = {}

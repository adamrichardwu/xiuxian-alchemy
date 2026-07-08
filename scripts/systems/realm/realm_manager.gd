# RealmManager - Cultivation realm state machine
extends Node

enum CultivationRealm {
	QI_REFINING,
	FOUNDATION,
	GOLDEN_CORE,
	NASCENT_SOUL,
	SPIRIT_TRANSFORM,
	INTEGRATION,
	MAHAYANA,
	TRIBULATION,
	ASCENDED
}

const REALM_NAMES = {
	0: "练气期",
	1: "筑基期",
	2: "金丹期",
	3: "元婴期",
	4: "化神期",
	5: "合体期",
	6: "大乘期",
	7: "渡劫期",
	8: "已飞升"
}

func get_current_realm() -> int:
	return GameState.realm

func get_realm_name(realm_idx: int = -1) -> String:
	if realm_idx < 0:
		realm_idx = GameState.realm
	return REALM_NAMES.get(realm_idx, "未知")

func can_breakthrough() -> bool:
	var realm_data = DataManager.get_realm(GameState.realm)
	if realm_data.is_empty():
		return false  # Already at max or data missing
	
	var cond = realm_data.get("breakthrough_conditions", {})
	
	if GameState.dao_insight < cond.get("min_dao_insight", 0.0):
		return false
	if GameState.pills_brewed_total < cond.get("min_pills_brewed", 0):
		return false
	
	# Check special conditions
	var special = cond.get("special", "")
	if special == "brew_3_pills_tier4_or_above":
		var count = 0
		for tier in GameState.pills_by_tier:
			if tier >= 4:
				count += GameState.pills_by_tier[tier]
		if count < 3:
			return false
	elif special == "brew_one_flawless_pill":
		if GameState.flawless_pills < 1:
			return false
	
	return true

func get_breakthrough_heart_demons() -> Array:
	var realm_data = DataManager.get_realm(GameState.realm)
	if realm_data.is_empty():
		return []
	return realm_data.get("heart_demon_pool", [])

func attempt_breakthrough(choice_index: int) -> Dictionary:
	if not can_breakthrough():
		return {"success": false, "reason": "条件未满足"}
	
	var success_chance = 0.5 + GameState.dao_insight * 0.4
	
	# Player choice affects outcome
	var heart_demons = get_breakthrough_heart_demons()
	if choice_index == 0 and heart_demons.size() > 0:
		success_chance += 0.15  # Slaying heart demon = orthodox path, easier
	
	var success = randf() < success_chance
	
	EventBus.realm_breakthrough_attempted.emit(GameState.realm, success)
	
	if success:
		var old_realm = GameState.realm
		GameState.realm = min(GameState.realm + 1, CultivationRealm.ASCENDED)
		GameState.dao_insight = 0.0  # Reset insight for next realm
		EventBus.realm_changed.emit(GameState.realm, get_realm_name())
		
		# Add route weight for slaying heart demon
		if choice_index == 0:
			var rw = DataManager.get_route_weight("slay_heart_demon")
			for route in ["orthodox", "cthulhu", "meta"]:
				var delta = rw.get(route, 0)
				if delta != 0:
					GameState.route_scores[route] = GameState.route_scores.get(route, 0) + delta
		elif choice_index == 1:
			var rw = DataManager.get_route_weight("accept_heart_demon")
			for route in ["orthodox", "cthulhu", "meta"]:
				var delta = rw.get(route, 0)
				if delta != 0:
					GameState.route_scores[route] = GameState.route_scores.get(route, 0) + delta
		
		return {"success": true, "old_realm": old_realm, "new_realm": GameState.realm, "realm_name": get_realm_name()}
	else:
		# Deviation path - corrupted breakthrough
		return {"success": false, "reason": "心魔吞噬", "deviation": true}

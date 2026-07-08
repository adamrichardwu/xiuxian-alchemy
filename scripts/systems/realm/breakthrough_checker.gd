# BreakthroughChecker - Validates breakthrough conditions
extends RefCounted

func check(realm_index: int, state: Dictionary) -> Dictionary:
	var realm_data = DataManager.get_realm(realm_index)
	if realm_data.is_empty():
		return {"can_breakthrough": false, "reason": "已是此界巅峰"}
	
	var cond = realm_data.get("breakthrough_conditions", {})
	var checks = []
	var all_pass = true
	
	# Dao insight check
	var insight_ok = state.get("dao_insight", 0.0) >= cond.get("min_dao_insight", 0.0)
	checks.append({"label": "丹道感悟", "pass": insight_ok, "current": state.get("dao_insight", 0.0), "required": cond.get("min_dao_insight", 0.0)})
	if not insight_ok: all_pass = false
	
	# Pills brewed check
	var pills_ok = state.get("pills_brewed_total", 0) >= cond.get("min_pills_brewed", 0)
	checks.append({"label": "炼丹次数", "pass": pills_ok, "current": state.get("pills_brewed_total", 0), "required": cond.get("min_pills_brewed", 0)})
	if not pills_ok: all_pass = false
	
	return {"can_breakthrough": all_pass, "checks": checks}

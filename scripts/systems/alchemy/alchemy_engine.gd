# AlchemyEngine - Core pill brewing simulation
extends RefCounted

# Temperature labels mapped to numeric values for calculation
const TEMP_MAP = {"cold": -1.0, "cool": -0.5, "neutral": 0.0, "warm": 0.5, "hot": 1.0}

# Quality labels by tier
const QUALITY_LABELS = {
	9: "无瑕",
	8: "极品",
	7: "上品",
	6: "中上",
	5: "中品",
	4: "中下",
	3: "下品",
	2: "劣质",
	1: "废丹"
}

# Simulate pill brewing with given inputs
func brew(herb_ids: Array[String], recipe_id: String, fire_accuracy: float) -> Dictionary:
	var recipe = DataManager.get_recipe(recipe_id)
	if recipe.is_empty():
		return _fail("丹方不存在")

	var target = recipe.get("target", {})
	
	# 1. Collect and sum herb properties
	var total_spirit = 0.0
	var total_toxicity = 0.0
	var temp_values = []
	var has_forbidden = false
	var used_herbs = []
	
	for herb_id in herb_ids:
		var herb = DataManager.get_herb(herb_id)
		if herb.is_empty():
			continue
		used_herbs.append(herb_id)
		var props = herb.get("properties", {})
		total_spirit += props.get("spirit_power", 0)
		total_toxicity += props.get("toxicity", 0.0)
		temp_values.append(TEMP_MAP.get(props.get("temperature", "neutral"), 0.0))
		if "forbidden" in props.get("tags", []):
			has_forbidden = true
	
	if used_herbs.is_empty():
		return _fail("没有放入任何药材")
	
	# Average temperature profile
	var avg_temp = 0.0
	for t in temp_values:
		avg_temp += t
	avg_temp /= temp_values.size()
	
	# 2. Fire accuracy (0.0 ~ 1.0) affects quality directly
	var fire_bonus = fire_accuracy
	
	# 3. Check for herb conflicts (penalty)
	var conflict_penalty = 0.0
	for i in range(used_herbs.size()):
		var herb_a = DataManager.get_herb(used_herbs[i])
		for j in range(i + 1, used_herbs.size()):
			if used_herbs[j] in herb_a.get("conflicts_with", []):
				conflict_penalty += 0.15
	
	# 4. Check for herb synergies (bonus)
	var synergy_bonus = 0.0
	for i in range(used_herbs.size()):
		var herb_a = DataManager.get_herb(used_herbs[i])
		for j in range(i + 1, used_herbs.size()):
			if used_herbs[j] in herb_a.get("synergy_with", []):
				synergy_bonus += 0.08
	
	# 5. Calculate quality tier (1-9)
	var spirit_score = clamp(total_spirit / max(target.get("min_spirit_power", 10), 1.0), 0.0, 3.0)
	var tox_penalty = 0.0
	if total_toxicity > target.get("max_toxicity", 0.1):
		tox_penalty = (total_toxicity - target.get("max_toxicity", 0.1)) * 2.0
	
	var quality_raw = 2.0
	quality_raw += spirit_score * 1.5
	quality_raw += fire_bonus * 2.0
	quality_raw += synergy_bonus * 1.5
	quality_raw -= conflict_penalty * 2.0
	quality_raw -= tox_penalty * 1.5
	
	var tier = clampi(roundi(quality_raw), 1, 9)
	
	# 6. Impurity ratio
	var impurity_ratio = clampf(total_toxicity / 0.5 + conflict_penalty * 0.5 - synergy_bonus * 0.3, 0.0, 1.0)
	
	# 7. Side effects
	var side_effects = []
	if impurity_ratio > 0.3:
		side_effects.append("轻微头晕")
	if impurity_ratio > 0.5:
		side_effects.append("灵力紊乱")
	if impurity_ratio > 0.7:
		side_effects.append("经脉灼痛")
	if has_forbidden:
		side_effects.append("妖气残留")
		impurity_ratio = max(impurity_ratio, 0.5)
	
	# 8. Flawless check
	var is_flawless = (tier >= 8 and impurity_ratio < 0.05 and not has_forbidden)
	
	# 9. Tribulation trigger
	var triggers_tribulation = tier >= 7
	
	# 10. Hidden variant check
	var variant_id = ""
	if "demon_blood_vine" in herb_ids and "nether_moss" in herb_ids:
		variant_id = "cthulhu_tainted"
	
	var result = {
		"success": true,
		"tier": tier,
		"quality_label": QUALITY_LABELS.get(tier, "未知"),
		"impurity_ratio": impurity_ratio,
		"side_effects": side_effects,
		"variant_id": variant_id,
		"tribulation_triggered": triggers_tribulation,
		"is_flawless": is_flawless,
		"spirit_power": total_spirit,
		"toxicity": total_toxicity,
		"has_forbidden": has_forbidden,
		"herbs_used": herb_ids,
		"recipe_id": recipe_id
	}
	
	# Apply route weights from recipe
	var recipe_rw = recipe.get("route_weight_on_brew", {})
	for route in ["orthodox", "cthulhu", "meta"]:
		var delta = recipe_rw.get(route, 0)
		if delta != 0:
			GameState.route_scores[route] = GameState.route_scores.get(route, 0) + delta
			EventBus.route_weight_changed.emit(route, delta)
	
	# Record in game state
	GameState.record_brew(tier, is_flawless)
	
	# Calculate dao insight gain
	var insight_gain = tier * 0.01
	if is_flawless:
		insight_gain += 0.05
	GameState.add_dao_insight(insight_gain)
	
	EventBus.brew_completed.emit(result)
	return result

func _fail(reason: String) -> Dictionary:
	return {
		"success": false,
		"tier": 0,
		"quality_label": "失败",
		"impurity_ratio": 1.0,
		"side_effects": [],
		"variant_id": "",
		"tribulation_triggered": false,
		"is_flawless": false,
		"spirit_power": 0,
		"toxicity": 0,
		"has_forbidden": false,
		"herbs_used": [],
		"recipe_id": "",
		"fail_reason": reason
	}

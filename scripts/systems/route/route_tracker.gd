# RouteTracker - Divine route weight accumulator
extends Node

enum DivineRoute {
	ORTHODOX,   # 仙道正统
	CTHULHU,    # 克苏鲁
	META,       # 次元觉醒
	HYBRID_CTHULHU_HEAVEN,  # 克苏鲁天庭
	HYBRID_AWAKENED_CTHULHU # 觉醒旧日
}

func apply_choice(choice_id: String):
	if GameState.route_flags.has(choice_id):
		return  # Already applied
	
	var rw = DataManager.get_route_weight(choice_id)
	var any_change = false
	
	for route in ["orthodox", "cthulhu", "meta"]:
		var delta = rw.get(route, 0)
		if delta != 0:
			GameState.route_scores[route] = GameState.route_scores.get(route, 0) + delta
			EventBus.route_weight_changed.emit(route, delta)
			any_change = true
	
	if any_change:
		GameState.route_flags[choice_id] = true

func get_scores() -> Dictionary:
	return GameState.route_scores.duplicate()

func get_dominant_route() -> DivineRoute:
	var s = GameState.route_scores
	var orthodox = s.get("orthodox", 0)
	var cthulhu = s.get("cthulhu", 0)
	var meta = s.get("meta", 0)
	
	# Hybrid: 克苏鲁天庭 (orthodox > 0 and cthulhu > orthodox/2)
	if orthodox > 3 and cthulhu > orthodox * 0.5:
		return DivineRoute.HYBRID_CTHULHU_HEAVEN
	
	# Hybrid: 觉醒旧日 (cthulhu dominant but meta also high)
	if cthulhu > 5 and meta > 3:
		return DivineRoute.HYBRID_AWAKENED_CTHULHU
	
	# Pure routes
	if meta >= orthodox and meta >= cthulhu and meta > 0:
		return DivineRoute.META
	if cthulhu >= orthodox and cthulhu >= meta and cthulhu > 0:
		return DivineRoute.CTHULHU
	return DivineRoute.ORTHODOX

func get_route_name(route: DivineRoute) -> String:
	match route:
		DivineRoute.ORTHODOX:
			return "仙道正统"
		DivineRoute.CTHULHU:
			return "禁忌窥视"
		DivineRoute.META:
			return "次元觉醒"
		DivineRoute.HYBRID_CTHULHU_HEAVEN:
			return "克苏鲁天庭"
		DivineRoute.HYBRID_AWAKENED_CTHULHU:
			return "觉醒旧日"
	return "未知"

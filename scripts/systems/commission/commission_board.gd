# CommissionBoard - Commission management logic
extends Node

var available_commissions: Array = []
var active_commission: Dictionary = {}

func refresh_commissions():
	available_commissions = DataManager.get_commissions_for_day(GameState.current_day, GameState.realm)

func accept_commission(commission_id: String) -> bool:
	var comm = DataManager.get_commission(commission_id)
	if comm.is_empty():
		return false
	
	GameState.active_commission_id = commission_id
	active_commission = comm
	EventBus.commission_accepted.emit(commission_id)
	return true

func complete_commission(outcome: String) -> Dictionary:
	if GameState.active_commission_id.is_empty():
		return {"error": "没有活跃委托"}
	
	var comm = active_commission
	if comm.is_empty():
		return {"error": "委托数据丢失"}
	
	GameState.completed_commissions.append(GameState.active_commission_id)
	
	var result = {"commission_id": GameState.active_commission_id, "outcome": outcome}
	
	# Apply rewards
	match outcome:
		"success":
			result["text"] = comm.get("success_text", "")
			_apply_rewards(comm, 1.0)
		"partial":
			result["text"] = comm.get("partial_success_text", comm.get("success_text", ""))
			_apply_rewards(comm, 0.5)
		"fail":
			result["text"] = comm.get("fail_text", "")
			_apply_rewards(comm, 0.0)
	
	# Apply route weight shifts
	var rw_shift = comm.get("route_weight_shift", {})
	for route in ["orthodox", "cthulhu", "meta"]:
		var delta = rw_shift.get(route, 0)
		if delta != 0:
			GameState.route_scores[route] = GameState.route_scores.get(route, 0) + delta
			EventBus.route_weight_changed.emit(route, delta)
	
	# Set flags
	for flag in comm.get("flags_set", []):
		GameState.set_flag(flag)
	
	# Clear active
	GameState.active_commission_id = ""
	active_commission = {}
	
	EventBus.commission_completed.emit(result["commission_id"], outcome)
	return result

func _apply_rewards(comm: Dictionary, multiplier: float):
	var money = comm.get("reward_money", 0) * multiplier
	if money > 0:
		pass  # TODO: Money system
	
	var insight = comm.get("reward_dao_insight", 0.0) * multiplier
	if insight > 0:
		GameState.add_dao_insight(insight)
	
	for item_id in comm.get("reward_items", []):
		GameState.add_herb(item_id)
		EventBus.herb_added.emit(item_id, 1)

func has_active_commission() -> bool:
	return not GameState.active_commission_id.is_empty()

func get_active_commission() -> Dictionary:
	return active_commission

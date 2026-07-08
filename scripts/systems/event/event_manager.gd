# EventManager - Story event scheduler
extends Node

func trigger_event(event_id: String):
	var ev = _find_event(event_id)
	if ev.is_empty():
		return
	
	EventBus.event_triggered.emit(event_id)
	
	# Show dialogue
	var lines = ev.get("text", [])
	for line in lines:
		EventBus.dialogue_show.emit(line, "")
		await get_tree().create_timer(0.1).timeout  # Small delay for processing
	
	# Show choices if any
	var choices = ev.get("choices", [])
	if choices.size() > 0:
		_show_choices(choices)

func check_day_start_events():
	var trigger_key = "day_start:%d" % GameState.current_day
	var events_list = DataManager.get_events_for_trigger(trigger_key)
	for ev in events_list:
		trigger_event(ev.get("id", ""))

func _find_event(event_id: String) -> Dictionary:
	for ev in DataManager.events.get("events", []):
		if ev.get("id") == event_id:
			return ev
	return {}

func _show_choices(choices: Array):
	var choice_data = []
	for c in choices:
		choice_data.append({
			"text": c.get("text", ""),
			"outcome": c.get("outcome", "")
		})
	EventBus.heart_demon_choice_requested.emit(choice_data)

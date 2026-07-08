# EventBus - Global signal hub singleton (autoload)
extends Node

# Herb / inventory signals
signal herb_added(herb_id: String, amount: int)
signal herb_removed(herb_id: String, amount: int)

# Alchemy signals
signal brew_started(recipe_id: String)
signal brew_completed(result: Dictionary)
signal tribulation_started(tier: int)
signal tribulation_ended(survived: bool)

# Realm signals
signal realm_breakthrough_attempted(old_realm: int, success: bool)
signal realm_changed(new_realm: int, new_name: String)
signal dao_insight_changed(new_value: float)
signal heart_demon_choice_requested(choices: Array)

# Commission signals
signal commission_accepted(commission_id: String)
signal commission_completed(commission_id: String, outcome: String)

# Route signals
signal route_weight_changed(route: String, delta: int)
signal route_threshold_crossed(route: String)

# Story signals
signal story_flag_set(flag: String)
signal event_triggered(event_id: String)
signal dialogue_show(text: String, speaker_id: String)

# Day cycle
signal day_advanced(new_day: int)

# UI signals
signal show_result_overlay(result: Dictionary)
signal hide_result_overlay()
signal show_dialogue_box()
signal hide_dialogue_box()

# EventBus - Global signal hub singleton
extends Node

signal herb_added(herb_id: String)
signal pill_brewed(result: Dictionary)
signal realm_breakthrough_attempted(old_realm: int, success: bool)
signal realm_changed(new_realm: int)
signal commission_completed(commission_id: String, outcome: String)
signal route_weight_changed(route: String, delta: int)
signal story_flag_set(flag: String)
signal tribulation_started(tier: int)

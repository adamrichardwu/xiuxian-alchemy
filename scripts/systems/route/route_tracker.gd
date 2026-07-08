# RouteTracker - Divine route weight accumulator
extends Node

var orthodox_score: int = 0
var cthulhu_score: int = 0
var meta_score: int = 0
var flags: Dictionary = {}

func add_weight(choice_id: String):
	pass  # TODO: Apply route weight from data

func get_dominant_route(include_hybrids: bool = true) -> int:
	return 0  # TODO: Calculate final route

# FireCurve - Temperature curve controller
extends RefCounted

var target_temperatures: Array[float] = []
var actual_temperatures: Array[float] = []

func match_quality(ideal_curve: Array) -> float:
	# TODO: Calculate how well player's fire matches ideal
	return 0.0

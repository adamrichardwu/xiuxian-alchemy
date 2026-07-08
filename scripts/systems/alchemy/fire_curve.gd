# FireCurve - Fire temperature curve helper
extends RefCounted

const CURVE_TYPES = {
	"gentle_rise":    [0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.7, 0.6],
	"low_sustain":    [0.2, 0.2, 0.3, 0.3, 0.3, 0.2, 0.2, 0.1],
	"wave_peak":      [0.3, 0.5, 0.7, 0.9, 0.6, 0.3, 0.7, 0.9],
	"steady_medium":  [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5],
	"tribulation_rise":[0.1, 0.2, 0.4, 0.6, 0.8, 0.9, 1.0, 1.0]
}

func get_ideal_curve(curve_name: String) -> Array:
	return CURVE_TYPES.get(curve_name, CURVE_TYPES["gentle_rise"])

# Match player's fire level (0.0-1.0) against the ideal curve at a given step
func match_at_step(player_fire: float, curve_name: String, step: int) -> float:
	var curve = get_ideal_curve(curve_name)
	if step >= curve.size():
		step = curve.size() - 1
	var ideal = curve[step]
	var diff = abs(player_fire - ideal)
	return clampf(1.0 - diff, 0.0, 1.0)

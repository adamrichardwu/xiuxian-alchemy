# EventData - Story event data class
extends Resource
@export var event_id: String = ""
@export var trigger_condition: String = ""
@export var dialogue_lines: Array[String] = []
@export var route_weight_shift: Dictionary = {}
@export var rewards: Dictionary = {}

# EventData - Resource class for story events
extends Resource
class_name EventData

@export var event_id: String = ""
@export var trigger: String = ""
@export_multiline var text: Array[String] = []

# CommissionData - Resource class for commissions
extends Resource
class_name CommissionData

@export var commission_id: String = ""
@export var day: int = 1
@export var client_id: String = ""
@export var title: String = ""
@export_multiline var request: String = ""
@export var required_pill: String = ""
@export var required_realm: int = 0

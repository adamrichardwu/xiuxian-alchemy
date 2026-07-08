# RealmUI - Realm display widget
extends Control

@onready var realm_name_label: Label = $RealmNameLabel
@onready var insight_progress: ProgressBar = $InsightProgress
@onready var breakthrough_btn: Button = $BreakthroughBtn

func _ready():
	EventBus.realm_changed.connect(_on_realm_changed)
	EventBus.dao_insight_changed.connect(_on_insight_changed)
	_update_display()

func _update_display():
	realm_name_label.text = RealmManager.get_realm_name()
	
	insight_progress.value = GameState.dao_insight
	insight_progress.max_value = 1.0
	
	if RealmManager.can_breakthrough():
		breakthrough_btn.visible = true
		breakthrough_btn.text = "突破至 %s" % RealmManager.get_realm_name(GameState.realm + 1)
	else:
		breakthrough_btn.visible = false

func _on_breakthrough_pressed():
	var heart_demons = RealmManager.get_breakthrough_heart_demons()
	if heart_demons.is_empty():
		RealmManager.attempt_breakthrough(0)
		return
	
	# Show heart demon choices
	var choices = []
	if heart_demons.size() > 0:
		choices.append({"text": "斩断心魔", "outcome": "slay"})
		choices.append({"text": "接纳心魔", "outcome": "accept"})
	EventBus.heart_demon_choice_requested.emit(choices)

func _on_realm_changed(_new_realm: int, _name: String):
	_update_display()

func _on_insight_changed(_value: float):
	insight_progress.value = GameState.dao_insight
	if _value >= 1.0:
		_update_display()

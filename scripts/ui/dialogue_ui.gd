# DialogueUI - Dialogue box controller
extends Control

@onready var text_label: RichTextLabel = $TextLabel
@onready var speaker_label: Label = $SpeakerLabel
@onready var choices_container: VBoxContainer = $ChoicesContainer
@onready var continue_indicator: Label = $ContinueIndicator

var current_lines: Array = []
var current_line_index: int = 0

func _ready():
	EventBus.dialogue_show.connect(_show_line)
	EventBus.heart_demon_choice_requested.connect(_show_choices)
	visible = false

func _show_line(text: String, speaker_id: String):
	visible = true
	current_lines = [text]
	current_line_index = 0
	
	text_label.text = text
	if speaker_id != "":
		var char_data = DataManager.get_character(speaker_id)
		speaker_label.text = char_data.get("name_cn", speaker_id)
		speaker_label.visible = true
	else:
		speaker_label.visible = false
	
	continue_indicator.visible = true
	choices_container.visible = false

func _show_choices(choices: Array):
	visible = true
	continue_indicator.visible = false
	
	for child in choices_container.get_children():
		child.queue_free()
	
	for i in range(choices.size()):
		var choice = choices[i]
		var btn = Button.new()
		btn.text = choice.get("text", "")
		var outcome = choice.get("outcome", "")
		btn.pressed.connect(_on_choice_selected.bind(outcome))
		choices_container.add_child(btn)
	
	choices_container.visible = true

func _on_choice_selected(outcome: String):
	visible = false
	if outcome.begins_with("begin_commission:"):
		var comm_id = outcome.replace("begin_commission:", "")
		CommissionBoard.accept_commission(comm_id)

func _input(event):
	if event is InputEventMouseButton and event.pressed and visible and continue_indicator.visible:
		visible = false

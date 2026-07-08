# HeartDemonScene - Breakthrough narrative controller
extends Control

var heart_demon_choices: Array = []
var on_choice_made: Callable

func start(choices: Array, callback: Callable):
	heart_demon_choices = choices
	on_choice_made = callback
	visible = true

func _on_choice_selected(index: int):
	visible = false
	if on_choice_made.is_valid():
		on_choice_made.call(index)

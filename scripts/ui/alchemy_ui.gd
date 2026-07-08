# AlchemyUI - Main alchemy screen controller
extends Control

@onready var furnace_view = /HBoxContainer/FurnaceView
@onready var herb_scroll = /HBoxContainer/HerbalScroll
@onready var recipe_scroll = /HBoxContainer/RecipeScroll
@onready var fire_slider = /FireControlBar/FireSlider

func _ready():
	pass  # TODO: Initialize UI bindings

func _on_brew_pressed():
	pass  # TODO: Start alchemy process

# Main - Game entry point
extends Node

func _ready():
	print("=== 修仙炼丹游戏 v0.1 ===")
	print("Day %d | Realm: %s | Dao Insight: %.0f%%" % [
		GameState.current_day,
		"练气期",
		GameState.dao_insight * 100
	])
	
	# Give starter herbs
	GameState.add_herb("spirit_grass", 5)
	GameState.add_herb("cold_marrow_flower", 3)
	GameState.add_herb("jade_lotus_seed", 2)
	
	# Add main UI
	var AlchemyUIScene = load("res://scripts/ui/alchemy_ui.gd")
	add_child(AlchemyUIScene.new())
	
	# Trigger day 1 intro event after a short delay
	await get_tree().create_timer(0.5).timeout
	EventManager.check_day_start_events()

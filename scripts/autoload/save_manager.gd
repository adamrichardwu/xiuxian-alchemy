# SaveManager - Save/Load singleton
extends Node

const SAVE_PATH = "user://save_slot_%02d.json"

func save(slot: int) -> bool:
	pass  # TODO: Serialize GameState to JSON

func load(slot: int) -> bool:
	pass  # TODO: Deserialize JSON to GameState

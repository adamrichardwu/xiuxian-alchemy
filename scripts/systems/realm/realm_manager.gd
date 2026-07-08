# RealmManager - Cultivation realm state machine
extends Node

enum CultivationRealm {
	QI_REFINING,
	FOUNDATION,
	GOLDEN_CORE,
	NASCENT_SOUL,
	SPIRIT_TRANSFORM,
	INTEGRATION,
	MAHAYANA,
	TRIBULATION,
	ASCENDED
}

var current_realm: CultivationRealm = CultivationRealm.QI_REFINING
var dao_insight: float = 0.0

func can_breakthrough() -> bool:
	return false  # TODO: Check realm conditions

func attempt_breakthrough(heart_demon_choice: int) -> bool:
	return false  # TODO: Heart demon scene + result

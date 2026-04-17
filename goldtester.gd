extends Label

func _ready() -> void:
	text = "Player gold: %d" % GameManager.player_gold
	GameManager.gold_changed.connect(_on_gold_changed)

func _on_gold_changed(team: GameManager.Team, new_amount: int) -> void:
	if team == GameManager.Team.PLAYER:
		text = "Player gold: %d" % new_amount

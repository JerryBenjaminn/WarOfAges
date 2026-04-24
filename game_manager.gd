extends Node

## Autoload singleton. Pitää kirjaa pelitilasta, kullasta ja joukkueista.

enum Team { PLAYER, ENEMY }

enum GameState { PLAYING, VICTORY, DEFEAT }

# Kulta per joukkue
const STARTING_GOLD: int = 50
const PASSIVE_INCOME_PER_SECOND: int = 5

var player_gold: int = STARTING_GOLD
var enemy_gold: int = STARTING_GOLD

var current_state: GameState = GameState.PLAYING

# Signaalit joita HUD ja muut nodet voivat kuunnella
signal gold_changed(team: Team, new_amount: int)
signal game_ended(result: GameState)

# Timer passiiviselle tulolle
var _income_timer: Timer

func _ready() -> void:
	_income_timer = Timer.new()
	_income_timer.wait_time = 1.0
	_income_timer.autostart = true
	_income_timer.timeout.connect(_on_income_tick)
	add_child(_income_timer)


func _on_income_tick() -> void:
	if current_state != GameState.PLAYING:
		return
	add_gold(Team.PLAYER, PASSIVE_INCOME_PER_SECOND)
	add_gold(Team.ENEMY, PASSIVE_INCOME_PER_SECOND)


func add_gold(team: Team, amount: int) -> void:
	if team == Team.PLAYER:
		player_gold += amount
		gold_changed.emit(Team.PLAYER, player_gold)
	else:
		enemy_gold += amount
		gold_changed.emit(Team.ENEMY, enemy_gold)


func try_spend_gold(team: Team, amount: int) -> bool:
	## Palauttaa true jos onnistui, false jos ei ollut varaa.
	if team == Team.PLAYER:
		if player_gold >= amount:
			player_gold -= amount
			gold_changed.emit(Team.PLAYER, player_gold)
			return true
		return false
	else:
		if enemy_gold >= amount:
			enemy_gold -= amount
			gold_changed.emit(Team.ENEMY, enemy_gold)
			return true
		return false


func get_gold(team: Team) -> int:
	return player_gold if team == Team.PLAYER else enemy_gold


func end_game(winning_team: Team) -> void:
	if current_state != GameState.PLAYING:
		return
	current_state = GameState.VICTORY if winning_team == Team.PLAYER else GameState.DEFEAT
	game_ended.emit(current_state)


func reset_game() -> void:
	player_gold = STARTING_GOLD
	enemy_gold = STARTING_GOLD
	current_state = GameState.PLAYING
	gold_changed.emit(Team.PLAYER, player_gold)
	gold_changed.emit(Team.ENEMY, enemy_gold)

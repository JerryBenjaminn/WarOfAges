extends Node2D

@export var unit_scene: PackedScene 
@export var player_data: UnitData
@export var enemy_data: UnitData


func _ready() -> void:
	spawn_unit(player_data, GameManager.Team.PLAYER, Vector2(100, 300))
	spawn_unit(enemy_data, GameManager.Team.ENEMY, Vector2(900, 300))


func spawn_unit(data: UnitData, team: GameManager.Team, pos: Vector2) -> void:
	var new_unit: Unit = unit_scene.instantiate()  # paikallinen nimi: new_unit
	new_unit.setup(data, team)
	new_unit.position = pos
	add_child(new_unit)

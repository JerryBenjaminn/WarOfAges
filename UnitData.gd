class_name UnitData
extends Resource

##Tämä on vähän niinkun Godotin "Scriptable Object"
##Aika siisti

@export var unit_name: String = "Caveman"

@export_group("Combat")
@export var max_hp: int = 30
@export var damage: int = 5
@export var attack_range: float = 40.0
@export var attack_cooldown: float = 1.0

@export_group("Movement")
@export var speed: float = 50.0

@export_group("Economy")
@export var cost: int = 25
@export var kill_reward: int = 10

@export_group("Visual")
@export var color: Color = Color.WHITE

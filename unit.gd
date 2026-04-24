class_name Unit
extends CharacterBody2D

## Yksikkö joka marssii vastustajaa kohti, taistelee kohdatessaan, kuolee HP:n loppuessa.
## MARCHING ja DEAD statet, liikkuminen ja vahinko

enum State { MARCHING, FIGHTING, DEAD }

var data: UnitData
var team: GameManager.Team
var move_direction: float  

var current_hp: int
var state: State = State.MARCHING

@onready var visual: ColorRect = $Visual


func setup(unit_data: UnitData, unit_team: GameManager.Team) -> void:
	data = unit_data
	team = unit_team
	current_hp = data.max_hp
	
	move_direction = 1.0 if team == GameManager.Team.PLAYER else -1.0
	
	collision_layer = 1 if team == GameManager.Team.PLAYER else 2


func _ready() -> void:
	if data:
		visual.color = data.color
	else:
		push_error("Unit has no data")


func _physics_process(delta: float) -> void:
	match state:
		State.MARCHING:
			_process_marching(delta)
		State.FIGHTING:
			pass  
		State.DEAD:
			pass 


func _process_marching(_delta: float) -> void:
	velocity.x = data.speed * move_direction
	velocity.y = 0
	move_and_slide()


func take_damage(amount: int, _attacker: Node) -> void:
	if state == State.DEAD:
		return
	current_hp -= amount
	if current_hp <= 0:
		die(_attacker)


func die(killer: Node) -> void:
	state = State.DEAD
	
	if killer and "team" in killer:
		var killer_team: GameManager.Team = killer.team
		GameManager.add_gold(killer_team, data.kill_reward)
	
	queue_free()

class_name Unit
extends CharacterBody2D

enum State { MARCHING, FIGHTING, DEAD }

var data: UnitData
var team: GameManager.Team
var move_direction: float

var current_hp: int
var state: State = State.MARCHING

var current_target: Node = null
var attack_timer: float = 0.0

@onready var visual: ColorRect = $Visual
@onready var attack_detector: Area2D = $AttackDetector
@onready var detector_shape: CollisionShape2D = $AttackDetector/CollisionShape2D


func setup(unit_data: UnitData, unit_team: GameManager.Team) -> void:
	data = unit_data
	team = unit_team
	current_hp = data.max_hp
	move_direction = 1.0 if team == GameManager.Team.PLAYER else -1.0
	collision_layer = 1 if team == GameManager.Team.PLAYER else 2


func _ready() -> void:
	if not data:
		push_error("Unit has no data")
		return
	
	visual.color = data.color
	
	if team == GameManager.Team.ENEMY:
		detector_shape.position.x = -detector_shape.position.x
	
	var shape: RectangleShape2D = detector_shape.shape
	shape.size.x = data.attack_range


func _physics_process(delta: float) -> void:
	match state:
		State.MARCHING:
			_process_marching()
		State.FIGHTING:
			_process_fighting(delta)
		State.DEAD:
			pass


func _process_marching() -> void:
	var enemy: Node = _find_enemy_in_range()
	if enemy:
		current_target = enemy
		state = State.FIGHTING
		attack_timer = 0.0
		velocity = Vector2.ZERO
		return
	
	velocity.x = data.speed * move_direction
	velocity.y = 0
	move_and_slide()


func _process_fighting(delta: float) -> void:
	if not is_instance_valid(current_target) or _is_target_dead(current_target):
		current_target = null
		state = State.MARCHING
		return
	
	attack_timer -= delta
	if attack_timer <= 0.0:
		current_target.take_damage(data.damage, self)
		attack_timer = data.attack_cooldown


func _find_enemy_in_range() -> Node:
	var bodies: Array[Node2D] = attack_detector.get_overlapping_bodies()
	for body in bodies:
		if body == self:
			continue
		if "team" in body and body.team != team:
			return body
	return null


func _is_target_dead(target: Node) -> bool:
	if "state" in target:
		return target.state == State.DEAD
	return false


func _team_name() -> String:
	if team == GameManager.Team.PLAYER:
		return "PLAYER"
	return "ENEMY"


func take_damage(amount: int, _attacker: Node) -> void:
	if state == State.DEAD:
		return
	current_hp -= amount
	if current_hp <= 0:
		die(_attacker)


func die(killer: Node) -> void:
	state = State.DEAD
	if killer and "team" in killer:
		GameManager.add_gold(killer.team, data.kill_reward)
	queue_free()

extends Node


@onready var boss = get_node("/root/Main/Boss")
@onready var bossAnimation = boss.get_node("AnimatedSprite2D")
@onready var bossLaserSpawnPoint = boss.get_node("laserSpawnPoint")
@onready var rock: PackedScene = preload("res://Scenes/boss_projectile.tscn")
@onready var playerG = get_node("/root/PlayerG")
@onready var bossProjectileSpawnPoint = boss.get_node("bossProjectileSpawnPoint")


var SPEED = 50.0
var health = 1000.0


enum state {IDLE, ATTACK1, LAZER, DEFLECT, DEAD, SHOOT}

var isAttacking = false
var isLaser = false
var isDeflecting = false
var isDead = false


var current_state = state.IDLE


func _ready() -> void:
	setState(state.IDLE)

func _process(delta: float) -> void:
	shootProjectile()


func setState(new_state):
	current_state = new_state
	match current_state:
		state.IDLE:
			bossAnimation.play("idle")
		state.ATTACK1:
			bossAnimation.play("attack 1")
		state.LAZER:
			bossAnimation.play("charge laser")


func shootProjectile():
	var projectile = rock.instantiate()
	projectile.global_position = bossProjectileSpawnPoint.global_position
	get_tree().root.add_child(projectile)
	


func calculatePlayerPosition() -> Vector2:
	var player_position = playerG.player.global_position
	return player_position
	
	
func calculateDirection() -> Vector2:
	return (calculatePlayerPosition() - boss.global_position).normalized()
	

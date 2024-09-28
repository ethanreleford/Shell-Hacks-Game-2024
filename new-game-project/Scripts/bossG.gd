extends Node

@onready var boss = get_node("/root/Main/Boss")
@onready var bossAnimation = boss.get_node("AnimatedSprite2D")
@onready var bossLaserSpawnPoint = boss.get_node("laserSpawnPoint")
@onready var rock: PackedScene = preload("res://Scenes/boss_projectile.tscn")
@onready var playerG = get_node("/root/PlayerG")
@onready var projectileSpawnPoint = boss.get_node("bossProjectileSpawnPoint")

var SPEED = 50.0
var health = 10000.0
var MIN_DISTANCE_TO_PLAYER = 100.0
var MAX_DISTANCE_TO_PLAYER = 250.0
var canWalk = true
var isMoving = false
var canShoot = true

var deltaG = 0.0

var current_state = state.IDLE
var timer: Timer

enum state {IDLE, ATTACK1, LAZER, DEFLECT, DEAD, SHOOT, SHOOTREVERSE}

func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = 5.0  # The boss will move for 5 seconds
	timer.one_shot = true  # We want the timer to only trigger once
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	setState(state.IDLE)

func _process(delta: float) -> void:
	deltaG = delta
  # Check player's distance every frame

func setState(new_state):
	current_state = new_state
	match current_state:
		state.IDLE:
			bossAnimation.play("idle")
		state.ATTACK1:
			boss.velocity = Vector2.ZERO
			bossAnimation.play("attack 1")
		state.LAZER:
			bossAnimation.play("charge laser")
		state.SHOOT:
			bossAnimation.play("shoot")
		state.SHOOTREVERSE:
			bossAnimation.play("shoot reverse")



func phase1():
	bossWalk(deltaG)
	if boss.isMeleeRange:
		punchAttack()





func punchAttack():
	setState(state.ATTACK1)
	await get_tree().create_timer(1.0).timeout
	if boss.isMeleeRange:
		playerG.takeDamage()
	



func shootProjectile():
	setState(state.SHOOT)
	await get_tree().create_timer(1.5).timeout
	if canShoot:
		canShoot = false
		var projectile = rock.instantiate()

		# Set the projectile's starting position to the boss's spawn point
		projectile.global_position = projectileSpawnPoint.global_position

		# Adjust the direction towards the center of the player or specific point
		var target_position = calculatePlayerPosition()

		# Calculate the direction from the spawn point to the target
		var direction = (target_position - projectile.global_position).normalized()

		# Set the direction for the projectile to move toward the adjusted target
		projectile.direction = direction
		
		# Optionally, rotate the projectile to face the direction it will move
		projectile.rotation = projectile.direction.angle()
		
		# Add the projectile to the same parent as the boss (to maintain the same scene structure)
		boss.get_parent().add_child(projectile)
		
		# Timer to allow shooting again after 2 seconds
		setState(state.SHOOTREVERSE)
		await get_tree().create_timer(2).timeout
		setState(state.IDLE)
		canShoot = true

# Helper function to calculate the player's position
func calculatePlayerPosition() -> Vector2:
	# Adjust to aim at the player's center or another specific point
	var player_center = playerG.player.global_position
	return player_center


# Check if the player is out of range and trigger movement
func checkPlayerDistance(delta: float) -> void:
	var player_position = calculatePlayerPosition()
	var distance_to_player = boss.global_position.distance_to(player_position)
	
	# If the player is beyond the maximum range and the boss is not already moving
	if distance_to_player > MAX_DISTANCE_TO_PLAYER and not isMoving:
		canWalk = true
		isMoving = true
		timer.start()  # Start the 5-second timer
		bossAnimation.play("walk")  # Play walk animation if applicable

	if canWalk:
		bossWalk(delta)

# Boss walks towards the player
func bossWalk(delta: float) -> void:
	if canWalk:
		var player_position = calculatePlayerPosition()
		var direction = (player_position - boss.global_position).normalized()
		boss.global_position += direction * SPEED * delta
		# Optionally, rotate boss to face the player

# Timer timeout: stop the boss after 5 seconds
func _on_timer_timeout() -> void:
	canWalk = false
	isMoving = false
	bossAnimation.play("idle")  # Switch to idle animation after walking



func takeDamage():
	health = health - 20
	if health <= 0:
		setState(state.DEAD)

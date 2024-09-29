extends Node

@onready var boss = get_node("/root/Main/Boss")
@onready var bossAnimation = boss.get_node("AnimatedSprite2D")
@onready var bossLaserSpawnPoint = boss.get_node("laserSpawnPoint")
@onready var rock: PackedScene = preload("res://Scenes/boss_projectile.tscn")
@onready var playerG = get_node("/root/PlayerG")
@onready var projectileSpawnPoint = boss.get_node("bossProjectileSpawnPoint")
@onready var laser: PackedScene = preload("res://Scenes/laser.tscn")


var SPEED = 25.0
var health = 5000.0
var MIN_DISTANCE_TO_PLAYER = 50.0
var MAX_DISTANCE_TO_PLAYER = 500.0
var canWalk = true
var isMoving = false
var canShoot = true
var cooldown : bool = true
var canSpeed: bool = true
var canSpawnLaser:bool = true



var deltaG = 0.0

var current_state = state.IDLE
var timer: Timer

enum state {IDLE, ATTACK1, LAZER, DEFLECT, DEAD, SHOOT, SHOOTREVERSE}

func reset():

	var SPEED = 25.0
	var health = 5000.0
	var MIN_DISTANCE_TO_PLAYER = 50.0
	var MAX_DISTANCE_TO_PLAYER = 500.0
	var canWalk = true
	var isMoving = false
	var canShoot = true
	var cooldown : bool = true
	var canSpeed: bool = true
	var canSpawnLaser:bool = true



	var deltaG = 0.0

	var current_state = state.IDLE
	var timer: Timer


func spawnLaser():
	var laser_instance = laser.instantiate()
	
	# Set the laser's starting position to the boss's laser spawn point
	laser_instance.global_position = bossLaserSpawnPoint.global_position
	
	# Add the laser to the scene
	add_child(laser_instance)
	
	# Add the laser instance to the current scene
	print("spawned")


func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = 5.0  # The boss will move for 5 seconds
	timer.one_shot = true  # We want the timer to only trigger once
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	setState(state.IDLE)

func _process(delta: float) -> void:
	deltaG = delta
	checkPlayerDistance(delta)
	# Ensure the boss is always looking toward the player
	updateBossFacingDirection(calculatePlayerPosition())
	

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
	increaseSpeed()
	bossWalk(deltaG)
	if boss.isMeleeRange:
		punchAttack()
	else:
		setState(state.IDLE)

func phase2():
	MIN_DISTANCE_TO_PLAYER = 225.0
	bossWalk(deltaG)
	if boss.isMeleeRange:
		punchAttack()
	else: 
		shootProjectile()
		
func phase3():
	increaseSpeed()
	bossWalk(deltaG)
	if boss.isLaserRange == true and canSpawnLaser:
		canSpawnLaser = false
		spawnLaser()
		await get_tree().create_timer(4).timeout
		canSpawnLaser = true
	elif boss.isMeleeRange:
		punchAttack()
	else: 
		shootProjectile()


func increaseSpeed():
	if canSpeed:
		print("increased")
		canSpeed = false
		SPEED = 40.0
		await get_tree().create_timer(5).timeout
		print("decreased")
		SPEED = 20.0
		await get_tree().create_timer(20).timeout
		print("reset")
		canSpeed = true

func punchAttack():
	setState(state.ATTACK1)
	await get_tree().create_timer(1.0).timeout
	if boss.isMeleeRange and cooldown:
		playerG.hurt()
		cooldown = false
		await get_tree().create_timer(1.5).timeout
		cooldown = true


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
		bossAnimation.play("idle")  # Play walk animation if applicable

	if canWalk:
		bossWalk(delta)

func bossWalk(delta: float) -> void:
	if canWalk:
		var player_position = calculatePlayerPosition()
		var direction = (player_position - boss.global_position).normalized()

		# Calculate the distance to the player
		var distance_to_player = boss.global_position.distance_to(player_position)

		# Only move the boss if it is farther than the minimum distance
		if distance_to_player > MIN_DISTANCE_TO_PLAYER:
			# Update boss position
			boss.global_position += direction * SPEED * delta
		else:
			canWalk = false
			await get_tree().create_timer(0.75).timeout
			canWalk = true

		# Always update the boss's facing direction
		updateBossFacingDirection(player_position)

# Update the boss's facing direction to look at the player
func updateBossFacingDirection(player_position: Vector2) -> void:
	var direction = (player_position - boss.global_position).normalized()
	# Flip the boss to face the player
	if direction.x > 0:  # Player is to the right of the boss
		boss.scale.x = abs(boss.scale.x)  # Ensure boss is facing right
	elif direction.x < 0:  # Player is to the left of the boss
		boss.scale.x = -abs(boss.scale.x)  # Flip boss to face left


# Timer timeout: stop the boss after 5 seconds
func _on_timer_timeout() -> void:
	canWalk = false
	isMoving = false
	bossAnimation.play("idle")  # Switch to idle animation after walking



func takeDamage():
	health = health - 20
	if health <= 0:
		setState(state.DEAD)
	playerG.hitEffect(boss, Color.CADET_BLUE, Color.WHITE)

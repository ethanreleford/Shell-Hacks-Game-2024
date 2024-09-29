extends Node

# Define movement variables
var speed: float = 90.0
var health : int = 100
var globalDirection : Vector2 = Vector2.ZERO
@onready var player = get_node("/root/Main/Player")
@onready var playerAnimation = player.get_node("AnimatedSprite2D")
@onready var playerBulletSpawnPoint = player.get_node("BulletSpawnPoint")
@onready var bossG = get_node("/root/BossG")

var ok = false
#different player states
enum playerState { IDLE, WALK, RUN, SHOOT1, SHOOT2, PUNCH1, HURT, DEAD, RELOAD}
var isShooting1 : bool  = false
var isShooting2 : bool  = false
var isRunning : bool = false
var isDead : bool = false
var isReloading : bool = false
var isHurt : bool = false
var current_state = playerState.IDLE
var runUpper = 100
var runCurrent = 100
var runLower = 0
var canRun = true
var ammoMax = 20
var ammo = 20


func reset():
	# Define movement variables
	var speed: float = 90.0
	var health : int = 100
	var globalDirection : Vector2 = Vector2.ZERO
	var player = get_node("/root/Main/Player")
	var playerAnimation = player.get_node("AnimatedSprite2D")
	var playerBulletSpawnPoint = player.get_node("BulletSpawnPoint")
	var bossG = get_node("/root/BossG")

	var ok = false
	#different player states
	var isShooting1 : bool  = false
	var isShooting2 : bool  = false
	var isRunning : bool = false
	var isDead : bool = false
	var isReloading : bool = false
	var isHurt : bool = false
	var current_state = playerState.IDLE
	var runUpper = 100
	var runCurrent = 100
	var runLower = 0
	var canRun = true
	var ammoMax = 20
	var ammo = 20




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_state == playerState.HURT:
		# Prevent other actions while the player is hurt
		return
	# Continue with other game logic (running, reloading, etc.)
	running()
	reloading()

	#print(playerAnimation)

# Function to get movement input
func get_input() -> Vector2:
	var direction: Vector2 = Vector2.ZERO
	direction.x = Input.get_axis("walk left", "walk right")
	direction.y = Input.get_axis("walk up", "walk down")
	if direction != Vector2.ZERO:
		globalDirection = direction
	if direction != Vector2.ZERO:
		direction = direction.normalized()
	return direction * speed

#function to change the states of animation
func setState(new_state):
	current_state = new_state
	match current_state:
		playerState.IDLE:
			playerAnimation.play("idle")
		playerState.WALK:
			playerAnimation.play("walk")
		playerState.RUN:
			playerAnimation.play("run")
		playerState.SHOOT1:
			playerAnimation.play("shoot 1")
		playerState.SHOOT2:
			playerAnimation.play("shoot 2")
		playerState.PUNCH1:
			playerAnimation.play("punch 1")
		playerState.HURT:
			playerAnimation.play("hurt")
		playerState.DEAD:
			playerAnimation.play("dead")
		playerState.RELOAD:
			playerAnimation.play("reload")
			
func animations(vector : Vector2):
# Get the global mouse position
	var mouse_position = player.get_global_mouse_position()

# Determine the player's x position
	var player_position = player.global_position.x  # Use the player's global position directly

# Flip the model based on mouse position
	if mouse_position.x > player_position:
		playerBulletSpawnPoint.position.x = 13.0
		playerAnimation.flip_h = false
	else:
		playerBulletSpawnPoint.position.x = -13.0
		playerAnimation.flip_h = true
	
	if isDead:
		setState(playerState.DEAD)
		player.velocity = Vector2(0,0)
		#here 
		return

	if isHurt:
		setState(playerState.HURT)
		return
		

	if isReloading:
		setState(playerState.RELOAD)
		isRunning = false
		await get_tree().create_timer(1.5).timeout
		return
		
	if isRunning:
		setState(playerState.RUN)
		return
		
	if isShooting1 and ammo >= 1:
		#print(isShooting)
		setState(playerState.SHOOT1)
		player.velocity = Vector2(0,0)
		return
		
		
	if vector.x > 0:
		setState(playerState.WALK)
	elif vector.x < 0:
		setState(playerState.WALK)
	if vector.y > 0:
		setState(playerState.WALK)
	elif vector.y < 0:
		setState(playerState.WALK)
	if vector == Vector2.ZERO:
		setState(playerState.IDLE )



func rechargeRun():
	if runCurrent < 100:
		await get_tree().create_timer(0.03).timeout
		runCurrent += 1


func useRun():
	runCurrent -= 1
	await get_tree().create_timer(0.02).timeout
	
func running():
	
	if Input.is_action_pressed("run") and runCurrent > 0 and canRun:
		useRun()
		isRunning = true
		speed = 135.0
	else:
		canRun = false
		rechargeRun()
		isRunning = false
		speed = 80.0
		#print("hit")
		await get_tree().create_timer(1).timeout
		canRun = true

func removeAmmo():
	ammo = ammo - 1

func reloading():
	if Input.is_action_just_pressed("reload"):
		isReloading = true
		#print(speed)
		await get_tree().create_timer(1.175).timeout
		ammo = ammoMax
		isShooting1 = false
		isReloading = false
		
		
func hurt():
	if isDead:
		return  # If the player is already dead, don't process any further damage.
	health -= 25  # Decrease health by 25 (or any amount)
	print("Player health:", health)
	isHurt = true
	hitEffect(player, Color.RED, Color.WHITE)
	# If health drops to 0 or below, trigger the dead state
	if health <= 0:
		isDead = true
		print("Player is dead")
	await get_tree().create_timer(0.5).timeout
	isHurt = false

func hitEffect(person, color1, color2):
	person.get_node("AnimatedSprite2D").modulate = color1
	await get_tree().create_timer(0.05).timeout
	person.get_node("AnimatedSprite2D").modulate = color2

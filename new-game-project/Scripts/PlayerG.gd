extends Node

# Define movement variables
var speed: float = 80.0
var health : int = 5
var globalDirection : Vector2 = Vector2.ZERO
@onready var player = get_node("/root/Main/Player")
@onready var playerAnimation = player.get_node("AnimatedSprite2D")
@onready var playerBulletSpawnPoint = player.get_node("BulletSpawnPoint")

#different player states
enum playerState { IDLE, WALK, RUN, SHOOT1, SHOOT2, PUNCH1, HURT, DEAD, RELOAD}
var isShooting : bool  = false
var isRunning : bool = false
var isDead : bool = false
var isReloading : bool = false
var current_state = playerState.IDLE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	running()
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
	if vector.x > 0:
		playerBulletSpawnPoint.position.x = 13.0
		playerAnimation.flip_h = false
	elif vector.x < 0:
		playerBulletSpawnPoint.position.x = -13.0
		playerAnimation.flip_h = true
	if isShooting:
		#print(isShooting)
		setState(playerState.SHOOT1)
		player.velocity = Vector2(0,0)
		return
	if isRunning:
		setState(playerState.RUN)
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


func running():
	if Input.is_action_pressed("run"):
		isRunning = true
		speed = 135.0
	else:
		isRunning = false
		speed = 80.0

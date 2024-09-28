extends Marker2D

var canShoot: bool = true
var timer: Timer
var delayTimer: Timer

@onready var bullet: PackedScene = preload("res://Scenes/bullet.tscn")
@onready var playerG = get_node("/root/PlayerG")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = 0.1  # Set the wait time to 0.1 seconds
	timer.one_shot = true    # Make it a one-shot timer
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)         # Add the timer as a child


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("shoot"):
		spawnBullet()

func spawnBullet():
	if canShoot:
		canShoot = false
		playerG.isShooting = true
		timer.start()
		
		# Create a new instance of the bullet
		var bullet_instance = bullet.instantiate()

		# Set the position of the bullet to the current position of this node (the marker)
		bullet_instance.global_position = global_position

		# Get the direction from the player (you mentioned you have `playerG.globalDirection`)
		var direction = playerG.globalDirection

		# Set the bullet's direction immediately
		bullet_instance.direction = direction

		# Add the bullet instance to the scene
		get_tree().root.add_child(bullet_instance)



func _on_timer_timeout() -> void:
	if !Input.is_action_pressed("shoot"):
		playerG.isShooting = false
	canShoot = true

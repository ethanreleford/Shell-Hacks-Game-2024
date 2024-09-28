extends Marker2D

var canShoot: bool = true
var timer: Timer
var delayTimer: Timer
var type : int 
var hasAmmo : bool = true

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
	chooseBullet()

func chooseBullet():
	if Input.is_action_pressed("shoot1"):
		timer.wait_time = 0.1
		var bullet_instance = bullet.instantiate()
		bullet_instance.damage = 25
		type = 1
		spawnBullet(bullet_instance)
	elif Input.is_action_just_pressed("shoot2"):
		timer.wait_time = 0.15
		var bullet_instance = bullet.instantiate()
		bullet_instance.damage = 50
		type = 2
		spawnBullet(bullet_instance)

func spawnBullet(bullet_instance):
	if canShoot and hasAmmo:
		playerG.removeAmmo()
		print(playerG.ammo)
		if playerG.ammo <= 0:
			return 
		canShoot = false
		if type == 1:
			playerG.isShooting1 = true
			bullet_instance.global_position = global_position
		elif type == 2:
			playerG.isShooting2 = true
			bullet_instance.global_position = global_position
		
		# Get the mouse position in global coordinates
		var mouse_position = get_global_mouse_position()

		# Calculate the direction from the bullet spawn point to the mouse
		var direction = (mouse_position - bullet_instance.global_position).normalized()
		
		# Set the bullet's direction
		bullet_instance.direction = direction

		# Add the bullet instance to the scene
		get_tree().root.add_child(bullet_instance)

		# Start the shooting cooldown
		timer.start()



func _on_timer_timeout() -> void:
	if !Input.is_action_pressed("shoot1") and !Input.is_action_just_pressed("shoot2") :
		#print(type)
		if type == 1:
			#print(type)
			playerG.isShooting1 = false
		elif type == 2:
			playerG.isShooting2 = false
	canShoot = true

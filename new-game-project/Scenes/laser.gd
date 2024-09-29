extends Node2D

@onready var spawn = get_node("Marker2D")
@onready var playerG = get_node("/root/PlayerG")


var startRotation  = false
var beginPlay = false
var laserPlay = false
var sat = false
# Rotation speed in radians per second
var rotation_speed: float = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	playAnimation()
	if laserPlay == true:
		rotation += rotation_speed * delta
	# Rotate the node slowly

func playAnimation():
	if sat == false:
		sat = true
		startAnimation()
		await get_tree().create_timer(2).timeout
		middleAnimation()

func startAnimation():
	$Marker2D/Area2D/CollisionShape2D.disabled = true
	if beginPlay == false:
		beginPlay = true
		$Marker2D/AnimatedSprite2D.play("ChargeUp")
		
func middleAnimation():
	$Marker2D/Area2D/CollisionShape2D.disabled = false
	if laserPlay == false:
		laserPlay = true
		$Marker2D/AnimatedSprite2D.play("Laser")
		await get_tree().create_timer(5).timeout
		queue_free()
		

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		playerG.hurt()

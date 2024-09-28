extends CharacterBody2D

@onready var playerG = get_node("/root/PlayerG")


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	# Get the movement from the global script
	velocity = playerG.get_input()
	playerG.animations(velocity)
	# Move the player with the calculated velocity
	move_and_slide()

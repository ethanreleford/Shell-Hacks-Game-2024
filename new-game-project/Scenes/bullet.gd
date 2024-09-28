extends RigidBody2D

# Speed at which the bullet should move
var speed : float = 1000.0
var direction : Vector2 = Vector2()

func _ready() -> void:
	# Ensure the bullet moves right away when spawned
	if direction != Vector2():
		linear_velocity = direction.normalized() * speed

func _process(delta: float) -> void:
	# Optional: Can be used if you want continuous movement logic
	# This would not be necessary if using RigidBody2D's physics system
	if direction != Vector2():
		position += direction.normalized() * speed * delta

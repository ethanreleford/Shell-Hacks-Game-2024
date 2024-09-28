extends RigidBody2D


@onready var bossG = get_node("/root/BossG")

# Speed at which the bullet should move
var speed : float = 700.0
var direction : Vector2 = Vector2()
var damage : int = 0
func _ready() -> void:
	# Ensure the bullet moves right away when spawned
	if direction != Vector2():
		linear_velocity = direction.normalized() * speed

func _process(delta: float) -> void:
	# Optional: Can be used if you want continuous movement logic
	# This would not be necessary if using RigidBody2D's physics system
	if direction != Vector2():
		position += direction.normalized() * speed * delta


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		bossG.takeDamage()
		queue_free()
		print(bossG.health)
